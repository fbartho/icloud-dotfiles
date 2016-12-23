import errno
import plistlib
import os.path

# Create user snippet directory if needed.
user_snippet_path = os.path.expanduser("~/Library/Developer/Xcode/UserData/CodeSnippets")
try: 
    os.makedirs(user_snippet_path)
except OSError, err:
    if err.errno != errno.EEXIST or not os.path.isdir(user_snippet_path): 
        raise

# Important, you'll need to quit and restart Xcode to notice the effects.
# Important, change this if you're on a Developer Preview of Xcode.
system_snippet_path = "/Applications/Xcode.app/Contents/PlugIns/IDECodeSnippetLibrary.ideplugin/Contents/Resources/SystemCodeSnippets.codesnippets"

print("Reading snippets from " + system_snippet_path)
plist = plistlib.readPlist(system_snippet_path)
for entry in plist:

    # Create a new user snippet file with modified
    # contents of the original snippet. Ignore paths that
    # already contain a user snippet to prevent overwriting
    # previously generated snippets.
    snippet_id = entry["IDECodeSnippetIdentifier"]
    snippet_path = user_snippet_path + "/" + snippet_id + ".codesnippet"
    if os.path.exists(snippet_path):
        print(snippet_path + " already exitsts: Skipping.")
        continue

    print("Writing " + snippet_path)

    # Marks the snippet as a user snippet. Xcode will
    # crash if a user snippet and a system snippet share
    # the same identifier.
    entry["IDECodeSnippetUserSnippet"] = True

    # Given two snippets with the same identifier,
    # Xcode will only show the snippet with the higher
    # "version number". This effectively hides the
    # default version of the snippet.
    entry["IDECodeSnippetVersion"] += 1

    plistlib.writePlist(entry, snippet_path)

print("Done writing snippets.")