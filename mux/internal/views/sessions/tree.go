package sessions

import (
	"sort"
	"strings"

	"github.com/miltonhit/mux/internal/tmux"
)

// NodeKind distinguishes session nodes from virtual group headers.
type NodeKind int

const (
	KindSession     NodeKind = iota
	KindGroupHeader          // virtual group (no real session)
)

// TreeNode represents one entry in the session tree.
type TreeNode struct {
	Kind        NodeKind
	Name        string // display name (suffix for children, full for root)
	SessionName string // raw tmux session name (empty for virtual headers)
	Windows     int
	Attached    bool
	Children    []*TreeNode
	Expanded    bool
	Depth       int
}

// BuildTree groups sessions using the same algorithm as tmux-sessionizer-list.sh.
//
// Rules:
//  1. Real parent-child: session "foo" exists AND session "foo-bar" exists
//     → "foo-bar" becomes a child of "foo".
//  2. Virtual groups: sessions share a dash prefix (e.g. "api-main", "api-tests")
//     but "api" does NOT exist → virtual header "api", both as children.
//  3. Sorting: -main and -master float to top within their group.
func BuildTree(sessions []tmux.Session) []*TreeNode {
	// Sort: -main/-master first within same prefix, then lexicographic.
	sorted := make([]tmux.Session, len(sessions))
	copy(sorted, sessions)
	sort.Slice(sorted, func(i, j int) bool {
		ki := sortKey(sorted[i].Name)
		kj := sortKey(sorted[j].Name)
		return ki < kj
	})

	nameSet := make(map[string]bool, len(sorted))
	for _, s := range sorted {
		nameSet[s.Name] = true
	}

	// For each session, find its longest real parent.
	parentOf := make(map[string]string)
	childrenOf := make(map[string][]string)
	for _, s := range sorted {
		parent := findRealParent(s.Name, nameSet)
		if parent != "" {
			parentOf[s.Name] = parent
			childrenOf[parent] = append(childrenOf[parent], s.Name)
		}
	}

	// Build session lookup
	sesMap := make(map[string]tmux.Session)
	for _, s := range sorted {
		sesMap[s.Name] = s
	}

	// For sessions without a real parent and without children, check virtual groups.
	type virtualChild struct {
		prefix string
	}
	virtualGroupOf := make(map[string]string) // session -> virtual prefix
	emittedVirtual := make(map[string]bool)

	for _, s := range sorted {
		if parentOf[s.Name] != "" || len(childrenOf[s.Name]) > 0 {
			continue
		}
		pfx := findGroupPrefix(s.Name, nameSet, sorted)
		if pfx != "" {
			virtualGroupOf[s.Name] = pfx
		}
	}

	// Assemble top-level nodes
	var roots []*TreeNode
	processed := make(map[string]bool)

	for _, s := range sorted {
		if processed[s.Name] {
			continue
		}

		// Skip children of real parents (they'll be nested)
		if parentOf[s.Name] != "" {
			continue
		}

		// Check if this belongs to a virtual group
		if pfx, ok := virtualGroupOf[s.Name]; ok {
			if emittedVirtual[pfx] {
				continue
			}
			emittedVirtual[pfx] = true

			header := &TreeNode{
				Kind:     KindGroupHeader,
				Name:     pfx,
				Expanded: true,
				Depth:    0,
			}
			// Gather all sessions in this virtual group
			for _, s2 := range sorted {
				if virtualGroupOf[s2.Name] == pfx {
					child := &TreeNode{
						Kind:        KindSession,
						Name:        strings.TrimPrefix(s2.Name, pfx+"-"),
						SessionName: s2.Name,
						Windows:     s2.Windows,
						Attached:    s2.Attached,
						Depth:       1,
					}
					header.Children = append(header.Children, child)
					processed[s2.Name] = true
				}
			}
			roots = append(roots, header)
			continue
		}

		// Real parent node with children
		if len(childrenOf[s.Name]) > 0 {
			node := &TreeNode{
				Kind:        KindSession,
				Name:        s.Name,
				SessionName: s.Name,
				Windows:     s.Windows,
				Attached:    s.Attached,
				Expanded:    true,
				Depth:       0,
			}
			for _, cname := range childrenOf[s.Name] {
				cs := sesMap[cname]
				child := &TreeNode{
					Kind:        KindSession,
					Name:        strings.TrimPrefix(cname, s.Name+"-"),
					SessionName: cname,
					Windows:     cs.Windows,
					Attached:    cs.Attached,
					Depth:       1,
				}
				node.Children = append(node.Children, child)
				processed[cname] = true
			}
			roots = append(roots, node)
			processed[s.Name] = true
			continue
		}

		// Standalone session
		roots = append(roots, &TreeNode{
			Kind:        KindSession,
			Name:        s.Name,
			SessionName: s.Name,
			Windows:     s.Windows,
			Attached:    s.Attached,
			Depth:       0,
		})
		processed[s.Name] = true
	}

	return roots
}

// Flatten returns the visible (expanded) nodes in order.
func Flatten(roots []*TreeNode) []*TreeNode {
	var out []*TreeNode
	for _, r := range roots {
		out = append(out, r)
		if r.Expanded {
			for _, c := range r.Children {
				out = append(out, c)
			}
		}
	}
	return out
}

// sortKey produces a key where -main/-master sort first within their prefix group.
func sortKey(name string) string {
	if strings.HasSuffix(name, "-main") {
		pfx := name[:len(name)-5]
		return pfx + "\x01main"
	}
	if strings.HasSuffix(name, "-master") {
		pfx := name[:len(name)-7]
		return pfx + "\x01master"
	}
	return name
}

// findRealParent returns the longest existing session name that is a dash-prefix of name.
func findRealParent(name string, nameSet map[string]bool) string {
	best := ""
	tmp := name
	for {
		idx := strings.LastIndex(tmp, "-")
		if idx < 0 {
			break
		}
		tmp = tmp[:idx]
		if nameSet[tmp] && len(tmp) > len(best) {
			best = tmp
		}
	}
	return best
}

// findGroupPrefix finds the longest dash-boundary prefix of name shared
// with at least one other session (that also has no real parent and no children).
func findGroupPrefix(name string, nameSet map[string]bool, all []tmux.Session) string {
	tmp := name
	for {
		idx := strings.LastIndex(tmp, "-")
		if idx < 0 {
			return ""
		}
		tmp = tmp[:idx]
		// Does any OTHER session match this prefix?
		for _, other := range all {
			if other.Name == name {
				continue
			}
			// The other must not be a real session with that exact prefix name
			// (that would be a real parent, not a virtual group)
			if other.Name == tmp {
				continue
			}
			if strings.HasPrefix(other.Name, tmp+"-") {
				return tmp
			}
		}
	}
}
