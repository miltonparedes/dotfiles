package sessions

import (
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"

	"github.com/miltonhit/mux/internal/app/messages"
	"github.com/miltonhit/mux/internal/tmux"
)

// Model is the sessions tree view.
type Model struct {
	roots   []*TreeNode
	visible []*TreeNode // flattened visible nodes
	cursor  int
	scroll  int
	height  int
	width   int

	confirming  bool // kill confirmation
	renaming    bool
	renameInput textinput.Model
	creating    bool
	newInput    textinput.Model
}

func New() Model {
	ri := textinput.New()
	ri.Prompt = "Rename: "
	ri.CharLimit = 64

	ni := textinput.New()
	ni.Prompt = "New session: "
	ni.CharLimit = 64

	return Model{
		renameInput: ri,
		newInput:    ni,
	}
}

func (m Model) Init() tea.Cmd {
	return m.loadSessions
}

func (m *Model) SetSize(w, h int) {
	m.width = w
	m.height = h
}

// IsEditing returns true when the user is in an input mode (rename, create, confirm).
func (m Model) IsEditing() bool {
	return m.confirming || m.renaming || m.creating
}

// SelectedSessionName returns the session name under the cursor, or empty string.
func (m Model) SelectedSessionName() string {
	if node := m.selected(); node != nil && node.Kind == KindSession {
		return node.SessionName
	}
	return ""
}

type sessionsLoadedMsg struct {
	sessions []tmux.Session
}

func (m Model) loadSessions() tea.Msg {
	sessions, err := tmux.ListSessions()
	if err != nil {
		return sessionsLoadedMsg{}
	}
	return sessionsLoadedMsg{sessions: sessions}
}

func (m Model) Update(msg tea.Msg) (Model, tea.Cmd) {
	switch msg := msg.(type) {
	case sessionsLoadedMsg:
		m.roots = BuildTree(msg.sessions)
		m.visible = Flatten(m.roots)
		m.clampCursor()
		return m, m.emitCursorChange()

	case tea.KeyMsg:
		if m.confirming {
			return m.handleConfirm(msg)
		}
		if m.renaming {
			return m.handleRename(msg)
		}
		if m.creating {
			return m.handleCreate(msg)
		}
		return m.handleNormal(msg)
	}
	return m, nil
}

func (m Model) handleNormal(msg tea.KeyMsg) (Model, tea.Cmd) {
	prevCursor := m.cursor

	switch msg.String() {
	case "j", "down":
		m.cursor++
		m.clampCursor()
		m.ensureVisible()
	case "k", "up":
		m.cursor--
		m.clampCursor()
		m.ensureVisible()
	case "g", "home":
		m.cursor = 0
		m.scroll = 0
	case "G", "end":
		m.cursor = len(m.visible) - 1
		m.ensureVisible()

	case "enter":
		if node := m.selected(); node != nil && node.Kind == KindSession {
			return m, func() tea.Msg {
				return messages.SwitchSessionMsg{Name: node.SessionName}
			}
		}

	case " ":
		if node := m.selected(); node != nil && len(node.Children) > 0 {
			node.Expanded = !node.Expanded
			m.visible = Flatten(m.roots)
			m.clampCursor()
		}

	case "l", "right", "tab":
		if node := m.selected(); node != nil && node.Kind == KindSession {
			return m, func() tea.Msg {
				return messages.DrillWindowsMsg{SessionName: node.SessionName}
			}
		}

	case "d":
		if node := m.selected(); node != nil && node.Kind == KindSession {
			m.confirming = true
		}

	case "r":
		if node := m.selected(); node != nil && node.Kind == KindSession {
			m.renaming = true
			m.renameInput.SetValue(node.SessionName)
			m.renameInput.Focus()
			return m, textinput.Blink
		}

	case "n":
		m.creating = true
		m.newInput.SetValue("")
		m.newInput.Focus()
		return m, textinput.Blink

	case "1", "2", "3", "4", "5", "6", "7", "8", "9":
		idx := int(msg.String()[0]-'0') - 1
		if msg.Alt && idx < len(m.visible) {
			m.cursor = idx
			m.ensureVisible()
		}
	}

	// Emit cursor change if cursor moved
	if m.cursor != prevCursor {
		return m, m.emitCursorChange()
	}
	return m, nil
}

func (m Model) handleConfirm(msg tea.KeyMsg) (Model, tea.Cmd) {
	switch msg.String() {
	case "y", "Y":
		m.confirming = false
		if node := m.selected(); node != nil && node.Kind == KindSession {
			name := node.SessionName
			return m, func() tea.Msg {
				tmux.KillSession(name)
				// Reload sessions from tmux after kill
				sessions, _ := tmux.ListSessions()
				return sessionsLoadedMsg{sessions: sessions}
			}
		}
	case "n", "N", "esc":
		m.confirming = false
	}
	return m, nil
}

func (m Model) handleRename(msg tea.KeyMsg) (Model, tea.Cmd) {
	switch msg.String() {
	case "enter":
		m.renaming = false
		if node := m.selected(); node != nil {
			old := node.SessionName
			newName := m.renameInput.Value()
			if newName != "" && newName != old {
				return m, func() tea.Msg {
					tmux.RenameSession(old, newName)
					return m.loadSessions()
				}
			}
		}
		return m, nil
	case "esc":
		m.renaming = false
		return m, nil
	}
	var cmd tea.Cmd
	m.renameInput, cmd = m.renameInput.Update(msg)
	return m, cmd
}

func (m Model) handleCreate(msg tea.KeyMsg) (Model, tea.Cmd) {
	switch msg.String() {
	case "enter":
		m.creating = false
		name := m.newInput.Value()
		if name != "" {
			return m, func() tea.Msg {
				tmux.NewSession(name)
				return m.loadSessions()
			}
		}
		return m, nil
	case "esc":
		m.creating = false
		return m, nil
	}
	var cmd tea.Cmd
	m.newInput, cmd = m.newInput.Update(msg)
	return m, cmd
}

func (m Model) selected() *TreeNode {
	if m.cursor >= 0 && m.cursor < len(m.visible) {
		return m.visible[m.cursor]
	}
	return nil
}

func (m *Model) clampCursor() {
	if m.cursor < 0 {
		m.cursor = 0
	}
	if m.cursor >= len(m.visible) {
		m.cursor = len(m.visible) - 1
	}
	if m.cursor < 0 {
		m.cursor = 0
	}
}

func (m *Model) ensureVisible() {
	// Each item takes 2 lines (item + separator), last takes 1.
	// Available lines = height - 2 (footer sep + help)
	avail := m.height - 2
	if avail < 1 {
		avail = 1
	}
	maxVisible := (avail + 1) / 2
	if maxVisible < 1 {
		maxVisible = 1
	}
	if m.cursor < m.scroll {
		m.scroll = m.cursor
	}
	if m.cursor >= m.scroll+maxVisible {
		m.scroll = m.cursor - maxVisible + 1
	}
}

func (m Model) emitCursorChange() tea.Cmd {
	name := m.SelectedSessionName()
	if name == "" {
		return nil
	}
	return func() tea.Msg {
		return messages.SessionCursorMsg{SessionName: name}
	}
}

// Reload triggers a session reload from tmux.
func (m Model) Reload() tea.Cmd {
	return m.loadSessions
}
