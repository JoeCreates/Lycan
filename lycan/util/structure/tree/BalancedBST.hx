package lycan.util.structure.tree;

// Balanced binary search tree based on the Haxe standard library implementation
class BalancedBST<K,V> {
    private var root:TreeNode<K,V>;
    private var comparator:K->K->Int;

    public function new(?comparator:K->K->Int) {
        if(comparator != null) {
            this.comparator = comparator;
        } else {
            this.comparator = compare;
        }
    }

    private function compare(k1:K, k2:K):Int {
        return Reflect.compare(k1, k2);
    }

    public function set(key:K, value:V):Void {
        root = setLoop(key, value, root);
    }

    public function get(key:K):Null<V> {
        var node = root;
        while (node != null) {
            var c = compare(key, node.key);
            if (c == 0) {
                return node.value;
            } if (c < 0) {
                node = node.left;
            } else {
                node = node.right;
            }
        }
        return null;
    }

    public function remove(key:K):Bool {
        try {
            root = removeLoop(key, root);
            return true;
        } catch (e:String) {
            return false;
        }
    }

    public function exists(key:K):Bool {
        var node = root;
        while (node != null) {
            var c = compare(key, node.key);
            if (c == 0) {
                return true;
            } else if (c < 0) {
                node = node.left;
            } else {
                node = node.right;
            }
        }
        return false;
    }

    public function iterator():Iterator<V> {
        var ret = [];
        iteratorLoop(root, ret);
        return ret.iterator();
    }

    public function keys():Iterator<K> {
        var ret = [];
        keysLoop(root, ret);
        return ret.iterator();
    }

    public function toString():String {
        return root == null ? '{}' : '{${root.toString()}}';
    }

    private function setLoop(k:K, v:V, node:TreeNode<K,V>):Void {
        if (node == null) {
            return new TreeNode<K,V>(null, k, v, null);
        }
        var c = compare(k, node.key);
        return if (c == 0) {
            new TreeNode<K,V>(node.left, k, v, node.right, node.get_height());
        }
        else if (c < 0) {
            var nl = setLoop(k, v, node.left);
            balance(nl, node.key, node.value, node.right);
        } else {
            var nr = setLoop(k, v, node.right);
            balance(node.left, node.key, node.value, nr);
        }
    }

    private function removeLoop(k:K, node:TreeNode<K,V>):Void {
        if (node == null) {
            throw "Not_found";
        }
        var c = compare(k, node.key);
        return if (c == 0) {
            merge(node.left, node.right);
        } else if (c < 0) {
            balance(removeLoop(k, node.left), node.key, node.value, node.right);
        } else {
            balance(node.left, node.key, node.value, removeLoop(k, node.right));
        }
    }

    private function iteratorLoop(node:TreeNode<K,V>, acc:Array<V>):Void {
        if (node != null) {
            iteratorLoop(node.left, acc);
            acc.push(node.value);
            iteratorLoop(node.right, acc);
        }
    }

    private function keysLoop(node:TreeNode<K,V>, acc:Array<K>):Void {
        if (node != null) {
            keysLoop(node.left, acc);
            acc.push(node.key);
            keysLoop(node.right, acc);
        }
    }

    private function balance(l:TreeNode<K,V>, k:K, v:V, r:TreeNode<K,V>):TreeNode<K,V> {
        var hl = l.get_height();
        var hr = r.get_height();
        return if (hl > hr + 2) {
            if (l.left.get_height() >= l.right.get_height()) new TreeNode<K,V>(l.left, l.key, l.value, new TreeNode<K,V>(l.right, k, v, r));
            else new TreeNode<K,V>(new TreeNode<K,V>(l.left,l.key, l.value, l.right.left), l.right.key, l.right.value, new TreeNode<K,V>(l.right.right, k, v, r));
        } else if (hr > hl + 2) {
            if (r.right.get_height() > r.left.get_height()) new TreeNode<K,V>(new TreeNode<K,V>(l, k, v, r.left), r.key, r.value, r.right);
            else new TreeNode<K,V>(new TreeNode<K,V>(l, k, v, r.left.left), r.left.key, r.left.value, new TreeNode<K,V>(r.left.right, r.key, r.value, r.right));
        } else {
            new TreeNode<K,V>(l, k, v, r, (hl > hr ? hl : hr) + 1);
        }
    }
}

class TreeNode<K,V> {
    public var left:TreeNode<K,V>;
    public var right:TreeNode<K,V>;
    public var key:K;
    public var value:V;
    #if as3
    public
    #end
    var _height:Int;

    public function new(l, k, v, r, h = -1) {
        left = l;
        key = k;
        value = v;
        right = r;
        if (h == -1) {
            _height = (left.get_height() > right.get_height() ? left.get_height() : right.get_height()) + 1;
        } else {
            _height = h;
        }
    }

    @:extern public inline function get_height() return this == null ? 0 : _height;

    public function toString():String {
        return (left == null ? "" : left.toString() + ", ") + '$key=$value' + (right == null ? "" : ", "  + right.toString());
    }
}