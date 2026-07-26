#!/usr/bin/env python3
"""Checks that the workbook ibx_smoke_test writes is a real .xlsx.

XlsxWriter.pas hand-rolls the format - an .xlsx is a zip of XML parts - so the
Pascal side can only assert that a file appeared. Whether that file is a valid
workbook has to be checked by taking it apart again, which is what this does:
zip integrity, the parts OOXML requires, that every part is well-formed XML,
and that the cells came out with the right types.

Structural only. It does not prove Excel opens the file; no spreadsheet reader
was available in the environment this was written in.
"""
import sys
import zipfile
import xml.etree.ElementTree as ET

NS = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
REQUIRED = [
    '[Content_Types].xml',
    '_rels/.rels',
    'xl/workbook.xml',
    'xl/_rels/workbook.xml.rels',
    'xl/worksheets/sheet1.xml',
]

def fail(msg):
    print('FAIL: ' + msg)
    sys.exit(1)

def main(path):
    try:
        z = zipfile.ZipFile(path)
    except zipfile.BadZipFile as e:
        fail('not a zip file: %s' % e)

    if z.testzip() is not None:
        fail('corrupt entry: %s' % z.testzip())

    names = z.namelist()
    for part in REQUIRED:
        if part not in names:
            fail('missing required part %s (have %s)' % (part, sorted(names)))

    for name in names:
        try:
            ET.fromstring(z.read(name))
        except ET.ParseError as e:
            fail('%s is not well-formed XML: %s' % (name, e))

    sheet = ET.fromstring(z.read('xl/worksheets/sheet1.xml'))
    rows = sheet.findall('.//%srow' % NS)
    if len(rows) < 2:
        fail('expected a header row and at least one data row, got %d' % len(rows))

    header = [c.findtext('%sis/%st' % (NS, NS)) for c in rows[0].findall('%sc' % NS)]
    if header != ['ID', 'NOTE']:
        fail('header row is %r, expected [ID, NOTE]' % header)

    # Row 2: a number in A, text needing XML escaping in B.
    cells = rows[1].findall('%sc' % NS)
    if cells[0].get('t') is not None:
        fail('an integer column was not written as a numeric cell')
    if cells[0].findtext('%sv' % NS) != '9001':
        fail('numeric cell holds %r' % cells[0].findtext('%sv' % NS))
    if cells[1].findtext('%sis/%st' % (NS, NS)) != 'a & b <c> "d"':
        fail('escaped text round-tripped as %r' % cells[1].findtext('%sis/%st' % (NS, NS)))

    # Row 3: NULL must be an empty cell, not an empty string.
    cells = rows[2].findall('%sc' % NS)
    if len(cells) != 2:
        fail('expected 2 cells in the NULL row, got %d' % len(cells))
    if list(cells[1]) or cells[1].get('t') is not None:
        fail('a NULL was written as a value rather than an empty cell')

    print('PASS: %s is a structurally valid workbook (%d rows).' % (path, len(rows)))

if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else '/tmp/ibx_smoke_export.xlsx')
