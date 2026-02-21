package sessions

import (
	"fmt"
	"strings"

	"github.com/miltonhit/mux/internal/theme"
)

func (m Model) View() string {
	if len(m.visible) == 0 {
		return theme.HelpStyle.Render(" No sessions found")
	}

	var b strings.Builder

	sepW := m.width - 2
	if sepW < 1 {
		sepW = 1
	}
	itemSep := " " + theme.TreeMeta.Render(strings.Repeat("─", sepW))

	// Each item = 2 lines (item + sep), last = 1. Footer = 2 lines (sep + help).
	// Available = height - 2
	avail := m.height - 2
	if avail < 1 {
		avail = 1
	}
	maxVisible := (avail + 1) / 2

	start := m.scroll
	end := start + maxVisible
	if end > len(m.visible) {
		end = len(m.visible)
	}

	for i := start; i < end; i++ {
		node := m.visible[i]
		selected := i == m.cursor
		b.WriteString(renderNode(node, selected))
		b.WriteString("\n")

		if i < end-1 {
			b.WriteString(itemSep)
			b.WriteString("\n")
		}
	}

	// Pad
	rendered := end - start
	linesUsed := rendered*2 - 1
	if rendered == 0 {
		linesUsed = 0
	}
	for linesUsed < avail {
		b.WriteString("\n")
		linesUsed++
	}

	// Footer
	footerSep := " " + theme.TreeConnector.Render(strings.Repeat("─", sepW))
	b.WriteString(footerSep)
	b.WriteString("\n")
	b.WriteString(m.StatusLine())

	return b.String()
}

// StatusLine returns the footer content.
func (m Model) StatusLine() string {
	if m.confirming {
		return theme.AttachedBadge.Render(" kill? y/n")
	}
	if m.renaming {
		return " " + m.renameInput.View()
	}
	if m.creating {
		return " " + m.newInput.View()
	}
	return theme.HelpStyle.Render(" ⏎ switch  ␣ fold  l win  q quit")
}

func renderNode(node *TreeNode, selected bool) string {
	if node.Kind == KindGroupHeader {
		indicator := "▾"
		if !node.Expanded {
			indicator = "▸"
		}
		name := fmt.Sprintf("%s %s", indicator, node.Name)
		if selected {
			return " " + theme.TreeNodeSelected.Render(name)
		}
		return " " + theme.TreeGroupHeader.Render(name)
	}

	meta := fmt.Sprintf("%dw", node.Windows)
	if node.Attached {
		meta += " " + theme.AttachedBadge.Render("●")
	}
	metaStr := theme.TreeMeta.Render(meta)

	if node.Depth > 0 {
		connector := theme.TreeConnector.Render("┊ ")
		if selected {
			return fmt.Sprintf(" %s%s  %s", connector, theme.TreeNodeSelected.Render(node.Name), metaStr)
		}
		return fmt.Sprintf(" %s%s  %s", connector, theme.TreeNodeNormal.Render(node.Name), metaStr)
	}

	if selected {
		return fmt.Sprintf(" %s  %s", theme.TreeNodeSelected.Render(node.Name), metaStr)
	}
	return fmt.Sprintf(" %s  %s", theme.TreeNodeNormal.Render(node.Name), metaStr)
}
