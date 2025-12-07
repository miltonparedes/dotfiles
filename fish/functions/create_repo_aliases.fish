function create_repo_aliases
    # Function to create aliases for repositories in Fish
    # Arguments: base_dir company_letter
    
    set -l base_dir $argv[1]
    set -l company_letter $argv[2]
    
    # Check if directory exists
    if not test -d "$base_dir"
        return
    end
    
    # Keep track of used aliases in a list
    set -l used_aliases
    
    for dir in $base_dir/*
        if test -d "$dir"
            set -l repo_name (basename "$dir")
            set -l first_letter (string sub -s 1 -l 1 "$repo_name")
            set -l alias_name "z$company_letter$first_letter"
            
            # Check if alias is already used
            if contains $alias_name $used_aliases
                # Try with first two letters
                set -l two_letters (string sub -s 1 -l 2 "$repo_name")
                set alias_name "z$company_letter$two_letters"
            end
            
            # If still conflicting, skip this repo
            if contains $alias_name $used_aliases
                echo "Warning: Conflicting alias for $repo_name, skipping."
                continue
            end
            
            # Create the alias function
            alias $alias_name="z $dir"
            set -a used_aliases $alias_name
        end
    end
end