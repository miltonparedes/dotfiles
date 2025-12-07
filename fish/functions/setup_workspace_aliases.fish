function setup_workspace_aliases
    # Setup workspace aliases for quick navigation
    # This function should be called in config.fish or conf.d/
    
    # Create aliases for company projects
    create_repo_aliases "$HOME/Workspaces/Company" "c"
    
    # Create aliases for third-party projects
    create_repo_aliases "$HOME/Workspaces/Thirdparty" "t"
    
    # Create aliases for personal projects (M directory)
    create_repo_aliases "$HOME/Workspaces/M" "m"
end