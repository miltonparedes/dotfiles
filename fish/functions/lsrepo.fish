function lsrepo --description "List all repository aliases"
    # List all workspace aliases created
    alias | grep "^z[ctm]" | sort
end