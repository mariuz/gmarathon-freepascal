import os
import re

BASE_DIR = '/home/mariuz/work/gmarathon-freepascal'
TARGET_DIRS = [
    "src/Source/",
    "src/Common/",
    "src/CreateDBWizard/",
    "src/ScriptExec/",
    "lib/Other/"
]

PAS_REPLACEMENTS = [
    # Class names
    (r'\bTIBDatabase\b', 'TIBConnection'),
    (r'\bTIB_Connection\b', 'TIBConnection'),
    (r'\bTIBTransaction\b', 'TSQLTransaction'),
    (r'\bTIB_Transaction\b', 'TSQLTransaction'),
    (r'\bTIBQuery\b', 'TSQLQuery'),
    (r'\bTIBOQuery\b', 'TSQLQuery'),
    (r'\bTIBSQL\b', 'TSQLQuery'),
    (r'\bTIB_Query\b', 'TSQLQuery'),
    (r'\bTIB_DSQL\b', 'TSQLQuery'),
    (r'\bTIBScript\b', 'TSQLScript'),
    (r'\bTIB_Script\b', 'TSQLScript'),
    (r'\bTIB_Process\b', 'TSQLScript'),

    # Properties / Methods
    (r'\.Path\b', '.DatabaseName'),
    (r'\.Server\b', '.HostName'),
    (r'\.SQLDialect\b', '.Dialect'),
    (r'\.InTransaction\b', '.Active'),
    (r'\.Started\b', '.Active'),
    
    # Remove/Comment assignments
    (r'(?i)\bRequestLive\s*:=\s*[^;]+;', r'// \g<0>'),
    (r'(?i)\bFetchWholeRows\s*:=\s*[^;]+;', r'// \g<0>'),
    (r'(?i)\bKeyLinksAutoDefine\s*:=\s*[^;]+;', r'// \g<0>'),
    
    # StatementType TODO
    (r'\.StatementType\b', r'.StatementType { TODO: StatementType not supported in TSQLQuery }'),
]

LFM_REPLACEMENTS = [
    (r'\bTIBDatabase\b', 'TIBConnection'),
    (r'\bTIB_Connection\b', 'TIBConnection'),
    (r'\bTIBTransaction\b', 'TSQLTransaction'),
    (r'\bTIB_Transaction\b', 'TSQLTransaction'),
    (r'\bTIBQuery\b', 'TSQLQuery'),
    (r'\bTIBOQuery\b', 'TSQLQuery'),
    (r'\bTIBSQL\b', 'TSQLQuery'),
    (r'\bTIB_Query\b', 'TSQLQuery'),
    (r'\bTIB_DSQL\b', 'TSQLQuery'),
    (r'\bTIBScript\b', 'TSQLScript'),
    (r'\bTIB_Script\b', 'TSQLScript'),
    (r'\bTIB_Process\b', 'TSQLScript'),
]

LFM_DELETE_PATTERNS = [
    r'^\s*FetchWholeRows\s*=\s*.*$',
    r'^\s*KeyLinksAutoDefine\s*=\s*.*$',
    r'^\s*RecordCountAccurate\s*=\s*.*$',
    r'^\s*FieldOptions\s*=\s*.*$',
    r'^\s*CallbackInc\s*=\s*.*$',
    r'^\s*RequestLive\s*=\s*.*$',
]

def update_uses_clause(content):
    replacements = {
        'IBDatabase': ['IBConnection', 'SQLDB'],
        'IB_Components': ['IBConnection', 'SQLDB'],
        'IB_Session': ['IBConnection', 'SQLDB'],
        'IBQuery': ['SQLDB'],
        'IBODataset': ['SQLDB'],
        'IBSQL': ['SQLDB'],
        'IB_DSQL': ['SQLDB'],
        'IBScript': ['SQLScript'],
        'IB_Process': ['SQLScript'],
        'IBHeader': ['{ IBHeader }'],
        'IB_Header': ['{ IB_Header }'],
        'IB_Monitor': ['{ IB_Monitor }'],
        'IBConnectionSQLDB': ['IBConnection', 'SQLDB'],
    }
    
    def replace_unit(match):
        uses_content = match.group(1)
        # Split by comma
        units = re.split(r',', uses_content)
        new_units_list = []
        added_units = set()
        
        for unit_part in units:
            trimmed = unit_part.strip()
            # Remove any existing comments for the check
            unit_name = re.sub(r'\{.*?\}', '', trimmed).strip()
            
            if unit_name in replacements:
                for rep in replacements[unit_name]:
                    rep_clean = rep.strip('{} ').lower()
                    if rep.startswith('{') or rep_clean not in added_units:
                        new_units_list.append(rep)
                        if not rep.startswith('{'):
                            added_units.add(rep_clean)
            elif unit_name:
                unit_clean = unit_name.lower()
                if unit_clean not in added_units:
                    new_units_list.append(trimmed)
                    added_units.add(unit_clean)
        
        return 'uses ' + ', '.join(new_units_list)

    content = re.sub(r'(?i)\buses\b(.*?)(?=;)', replace_unit, content, flags=re.DOTALL)
    return content

def refactor_pas(file_path):
    with open(file_path, 'r', encoding='latin-1') as f:
        content = f.read()
    
    new_content = update_uses_clause(content)
    for pattern, replacement in PAS_REPLACEMENTS:
        new_content = re.sub(pattern, replacement, new_content)
    
    if new_content != content:
        with open(file_path, 'w', encoding='latin-1') as f:
            f.write(new_content)
        return True
    return False

def refactor_lfm(file_path):
    with open(file_path, 'r', encoding='latin-1') as f:
        lines = f.readlines()
    
    new_lines = []
    changed = False
    for line in lines:
        skip = False
        for pattern in LFM_DELETE_PATTERNS:
            if re.match(pattern, line, re.IGNORECASE):
                skip = True
                changed = True
                break
        if skip:
            continue
        
        new_line = line
        for pattern, replacement in LFM_REPLACEMENTS:
            updated_line = re.sub(pattern, replacement, new_line)
            if updated_line != new_line:
                new_line = updated_line
                changed = True
        
        new_lines.append(new_line)
    
    if changed:
        with open(file_path, 'w', encoding='latin-1') as f:
            f.writelines(new_lines)
        return True
    return False

def main():
    for target_dir in TARGET_DIRS:
        abs_dir = os.path.join(BASE_DIR, target_dir)
        if not os.path.exists(abs_dir):
            continue
        for root, _, files in os.walk(abs_dir):
            for file in files:
                file_path = os.path.join(root, file)
                if file.endswith('.pas'):
                    try:
                        refactor_pas(file_path)
                    except Exception:
                        pass
                elif file.endswith('.lfm') or file.endswith('.dfm'):
                    try:
                        refactor_lfm(file_path)
                    except Exception:
                        pass

if __name__ == "__main__":
    main()
