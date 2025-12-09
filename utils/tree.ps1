using namespace System.Collections.Generic

class Node {
    [List[Node]] $Children
    [Node] $Parent
    [bool] IsLeaf() { return (0 -eq $this.Children.Count) }
    [bool] IsRoot() { return ($null -eq $this.Parent) }

    Node([Node]$parent) {
        $this.Parent = $parent
        $this.Children = [List[Node]]::new()
    }

    [Node] AddChild() {
        $node = [Node]::new($this)
        $this.Children.Add($node)
        return $node
    }
    
    [Tree] GetRoot() {
        if ($this.IsRoot()) {
            return [Tree]$this
        }
        else {
            return $this.Parent.GetRoot()
        }
    }

    [int] CountLeaves() {
        if ($this.IsLeaf()) {
            return 1
        }
        else {
            return $(
                $this.Children | ForEach-Object {
                    $_.CountLeaves()
                }
            ) | Measure-Object -Sum | Select-Object -Expand Sum
        }
    }
}

class Tree : Node {
    Tree() : base($null) {
    }
}

# $tree = [Tree]::new()
# $1 = $tree.AddChild()
# $2 = $1.AddChild()
# $3 = $1.AddChild()
# $4 = $2.AddChild()
# $5 = $2.AddChild()
# ""
# $tree.CountLeaves()
# ""
# $5.GetRoot().GetType()