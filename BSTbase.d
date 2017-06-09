import std.stdio: writeln;
import core.stdc.stdlib: exit;

class BSTbase(T) {

  private bool found = false;
  private int size = 0;

  private tree_node * root = null;
  private tree_node * targetNode = null;
  private tree_node * parent = null;

  private struct tree_node {
    T payload;
    real val = 0.0;
    tree_node * left = null;
    tree_node * right = null;
  }

  public final int getSize() { return size; }

  public void insert(T item, real val) {
    if(searchTree(val)) {
      return;
    } else {
      addNode(item, val);
    }
  }

  public bool searchTree(real val) {
    return finder(root, val);
  }

  public void remove(real val) {
    if(!searchTree(val)) {
      return;
    } else if(isLeaf(targetNode)) {
      removeLeaf(targetNode);
    } else {
      removeNonLeaf();
    } size--;
  }

  private final void addNode(T item, real val) {
    if(root is null) {
      root = new tree_node();
      root.payload = item;
      root.val = val;
    } else if(val > targetNode.val) {
      targetNode.right = new tree_node();
      targetNode.right.payload = item;
      targetNode.right.val = val;
    } else {
      targetNode.left = new tree_node();
      targetNode.left.payload = item;
      targetNode.left.val = val;
    } size++;
  }

  private final bool finder(tree_node * current, real val) {
    if(current is null) { return false; }
    bool found = false;
    targetNode = current;
    if(current.val > val) {
      parent = current;
      found = finder(current.left, val);
    } else if(current.val < val){
      parent = current;
      found = finder(current.right, val);
    } else {
      found = true;
    }
    return found;
  }

  private final bool isLeaf(tree_node * current) {
    return ((current.left is null) && (current.right is null));
  }

  private final void removeLeaf(tree_node * current) {
    if(current is root) {
      root = null;
    } else if(parent.left is current) {
      parent.left = null;
    } else {
      parent.right = null;
    }
  }

  private final void removeNonLeaf() {
    tree_node * replacement = null;
    parent = targetNode;
    if(!(targetNode.right is null)) {
      replacement = getNextLargest(targetNode.right);
    } else {
      replacement = getNextSmallest(targetNode.left);
    } removeReplacement(replacement);
  }

  private final tree_node * getNextLargest(tree_node * current) {
    while(!(current.left is null)) {
      parent = current;
      current = current.left;
    } return current;
  }

  private final tree_node * getNextSmallest(tree_node * current) {
    while(!(current.right is null)) {
      parent = current;
      current = current.right;
    } return current;
  }

  private final void removeReplacement(tree_node * replacement) {
    targetNode.payload = replacement.payload;
    targetNode.val = replacement.val;

    if(isLeaf(replacement)) {
      removeLeaf(replacement);
    } else if(parent.left is replacement) {
      if(!(replacement.right is null)){
        parent.left = replacement.right;
      } else {
        parent.left = replacement.left;
      }
    } else {
      if(!(replacement.left is null)) {
        parent.right = replacement.left;
      } else {
        parent.right = replacement.right;
      }
    }
  }
}



unittest {
  auto tree = new BSTbase!int;
  for(int i = 1; i <= 10000; i++) {
    tree.insert(i, cast(real) i);
    assert(tree.getSize() == i);
  }
  for(int j = 10001; j >= 0; j--) {
    tree.remove(cast(real) j);
  }
  assert(tree.getSize() == 0);
}

unittest {
  auto tree = new BSTbase!int;
  tree.insert(3, cast(real) 3);
  assert(tree.getSize() == 1);
  assert(tree.searchTree(cast(real) 3));
}

unittest {
  auto tree = new BSTbase!int;
  for(int i = 0; i < 10001; i++) {
    tree.insert(i, cast(real) i);
    assert(tree.searchTree(i));
  }

  for(int i = 0; i < 10001; i++) {
    tree.remove(cast(real) i);
    assert(!tree.searchTree(cast(real) i));
  }
  assert(tree.getSize() == 0);

  for(int i = 10000; i >= 0; i--) {
    tree.insert(i, cast(real) i);
    assert(tree.searchTree(i));
  }

  for(int i = 10000; i >= 0; i--) {
    tree.remove(cast(real) i);
    assert(!tree.searchTree(cast(real) i));
  }
  assert(tree.getSize() == 0);
}

unittest {
  import std.random;
  auto tree = new BSTbase!int;
  for(int i = 1; i <= 10; i++) {
    int rand = 0;
    for(int j = 0; j < 1000000; j++) {
      rand = uniform(-1000000, 1000000);
      tree.insert(rand, cast(real) rand);
      assert(tree.searchTree(cast(real) rand));
    }

    for(int k = -1000001; k <= 1000001; k++) {
      tree.remove(cast(real) k);
      assert(!tree.searchTree(cast(real) k));
    }
    assert(tree.getSize() == 0);
  }
}

unittest {
  class thingy {}
  import Stack: Stack;
  auto stack = new Stack!thingy;
  auto tree = new BSTbase!thingy;

  for(int i = 0; i < 10000; i++) {
    auto thing = new thingy;
    stack.push(thing);
    tree.insert(thing, cast(real) (cast(void*)thing));
    assert(tree.searchTree(cast(real) (cast(void*)thing)));
  }
  for(int i = 0; i < 10000; i++) {
    auto thing = stack.pop();
    tree.remove(cast(real) (cast(void*)thing));
    assert(!tree.searchTree(cast(real) (cast(void*)thing)));
  }
  assert(tree.getSize() == 0);
}
