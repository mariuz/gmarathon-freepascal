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
    (r'\bTIB_Monitor\b', 'TIBSQLMonitor'),
    (r'\bTIB_Cursor\b', 'TIBSQL'),
    (r'\bTIB_StoredProc\b', 'TIBStoredProc'),
    (r'\bTIB_Events\b', 'TIBEvents'),
]

def refactor_file(file_path):
    if not os.path.exists(file_path):
        return

    with open(file_path, 'r', encoding='latin-1') as f:
        content = f.read()

    new_content = content
    for pattern, replacement in replacements:
        new_content = re.sub(pattern, replacement, new_content)
    
    # Clean up duplicate units in uses clause
    lines = new_content.splitlines()
    in_uses = False
    for i in range(len(lines)):
        line = lines[i]
        if line.strip().lower().startswith('uses'):
            in_uses = True
        
        if in_uses:
            parts = line.split(',')
            new_parts = []
            seen = set()
            changed = False
            for p in parts:
                p_clean = p.strip().strip(';').strip()
                if p_clean.lower() in seen and p_clean:
                    changed = True
                    continue
                if p_clean:
                    seen.add(p_clean.lower())
                new_parts.append(p)
            
            if changed:
                lines[i] = ','.join(new_parts)
                if line.endswith(';'):
                     if not lines[i].endswith(';'):
                         lines[i] += ';'

        if line.strip().endswith(';'):
            in_uses = False

    new_content = '\n'.join(lines)

    if new_content != content:
        with open(file_path, 'w', encoding='latin-1') as f:
            f.write(new_content)
        print(f"Updated {file_path}")

for f in files:
    refactor_file(os.path.join('/home/mariuz/work/gmarathon-freepascal', f))
