# openx.fish - Open Xcode workspace/project/Package.swift
# Priority: .xcworkspace > .xcodeproj > Package.swift

function openx --description "Open Xcode workspace, project, or Package.swift"
    # Try xcworkspace first
    set -l workspace (find . -maxdepth 1 -name "*.xcworkspace" | head -1)
    if test -n "$workspace"
        echo "Opening $workspace"
        xed "$workspace"
        return
    end

    # Try xcodeproj
    set -l project (find . -maxdepth 1 -name "*.xcodeproj" | head -1)
    if test -n "$project"
        echo "Opening $project"
        xed "$project"
        return
    end

    # Try Package.swift
    if test -f "Package.swift"
        echo "Opening Package.swift"
        xed "Package.swift"
        return
    end

    echo "No Xcode files to open."
end

# Shorthand alias
alias xcp="openx"
alias podxcp="pod install && openx"
