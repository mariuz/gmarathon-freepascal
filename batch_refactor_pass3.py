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
    (r'\bTIB_COnnection\b', 'TIBDatabase'),
    (r'\bTIB_Connection\b', 'TIBDatabase'),
]

def refactor_file(file_path):
    if not os.path.exists(file_path):
        return

    with open(file_path, 'r', encoding='latin-1') as f:
        content = f.read()

    new_content = content
    for pattern, replacement in replacements:
        new_content = re.sub(pattern, replacement, new_content)

    if new_content != content:
        with open(file_path, 'w', encoding='latin-1') as f:
            f.write(new_content)
        print(f"Updated {file_path}")

for f in files:
    refactor_file(os.path.join('/home/mariuz/work/gmarathon-freepascal', f))
