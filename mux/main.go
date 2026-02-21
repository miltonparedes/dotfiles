package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"

	"github.com/miltonhit/mux/internal/app"
)

func main() {
	mode := app.ModeSidebar
	for _, arg := range os.Args[1:] {
		switch arg {
		case "--palette", "-p":
			mode = app.ModePalette
		case "--worktrees", "-w":
			mode = app.ModeWorktrees
		case "--agents", "-a":
			mode = app.ModeAgents
		}
	}

	p := tea.NewProgram(app.New(mode), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "mux: %v\n", err)
		os.Exit(1)
	}
}
