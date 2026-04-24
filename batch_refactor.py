import os
import re

files = [
    "src/Source/EditorGenerator.pas",
    "src/Source/SQLTrace.pas",
    "src/Source/EditorGrant.pas",
    "src/Source/FrameDependencies.pas",
    "src/Source/DropObject.pas",
    "src/Source/CompileDBObject.pas",
    "src/Source/FramePermissions.pas",
    "src/Source/MetaDataSearchObject.pas",
    "src/Source/IBDebuggerVM.pas",
    "src/Source/EditorDomain.pas",
    "src/Source/EditorColumn.pas",
    "src/Source/EditorView.pas",
    "src/Source/EditorStoredProcedure.pas",
    "src/Source/EditorTrigger.pas",
    "src/Source/EditorIndex.pas",
    "src/Source/FrameDescription.pas",
    "src/Source/EditorConstraint.pas",
    "src/Source/EditorUDF.pas",
    "src/Source/FrameMetadata.pas",
    "src/Source/UserEditor.pas",
    "src/Source/ParseCollection.pas",
    "src/Source/EditorException.pas",
    "src/CreateDBWizard/CreateDatabase.pas",
    "src/ScriptExec/ScriptMain.pas",
    "src/Common/ScriptExecutive.pas",
    "lib/Other/IBPerformanceMonitor.pas"
]

replacements = [
    (r'\bIB_Components\b', 'IBDatabase'),
    (r'\bIBODataset\b', 'IBQuery'),
    (r'\bIB_Session\b', 'IBDatabase'),
    (r'\bIB_Process\b', 'IBScript'),
    (r'\bIB_Monitor\b', 'IBSQLMonitor'),
    (r'\bIB_Header\b', 'IBHeader'),
    
    (r'\bTIB_Connection\b', 'TIBDatabase'),
    (r'\bTIB_Transaction\b', 'TIBTransaction'),
    (r'\bTIBOQuery\b', 'TIBQuery'),
    (r'\bTIB_Query\b', 'TIBQuery'),
    (r'\bTIB_Script\b', 'TIBScript'),
    (r'\bTIB_DSQL\b', 'TIBSQL'),
    (r'\bTIB_Cursor\b', 'TIBSQL'), # Often TIB_Cursor maps to TIBSQL or TIBQuery in IBX
    
    (r'\.IB_Connection\b', '.Database'),
    (r'\.IB_Transaction\b', '.Transaction'),
    (r'\bTransaction\.Started\b', 'Transaction.InTransaction'),
    (r'\bConnection\.Connected\b', 'Connected'),
]

def refactor_file(file_path):
    print(f"Processing {file_path}")
    if not os.path.exists(file_path):
        print(f"File {file_path} not found.")
        return

    with open(file_path, 'r', encoding='latin-1') as f:
        content = f.read()

    new_content = content
    for pattern, replacement in replacements:
        new_content = re.sub(pattern, replacement, new_content)
    
    # RequestLive := True/False -> comment out
    new_content = re.sub(r'(\bRequestLive\s*:=\s*(True|False)\s*;)', r'// \1', new_content, flags=re.IGNORECASE)

    if new_content != content:
        # Check for duplicate units in uses clauses (very basic check)
        # Find 'uses' blocks and remove duplicates
        def remove_duplicates(match):
            units = match.group(1).split(',')
            seen = set()
            new_units = []
            for u in units:
                trimmed = u.strip()
                if trimmed.lower() not in seen:
                    new_units.append(u)
                    seen.add(trimmed.lower())
            return f"uses{','.join(new_units)}"

        # This is a bit risky with complex uses clauses, but let's try a simpler approach if needed.
        # Actually, let's just write it and see.
        
        with open(file_path, 'w', encoding='latin-1') as f:
            f.write(new_content)
        print(f"Updated {file_path}")
    else:
        print(f"No changes needed for {file_path}")

for f in files:
    refactor_file(os.path.join('/home/mariuz/work/gmarathon-freepascal', f))
