import std.stdio: writeln;
import core.stdc.stdlib: exit;
import core.memory;


class BST(T) {

  private bool found = false;
  private int size = 0;
  private T[] transfer;

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

  public final void insert(T item) {
    reset();
    if(searchTree(item)) {
      return;
    } else {
      addNode(item, cmp(item));
    } reset();
  }

  public final bool searchTree(T item) {
    return finder(root, cmp(item));
  }

  public final void remove(T item) {
    reset();
    if(!searchTree(item)) {
      return;
    } else if(isLeaf(targetNode)) {
      removeLeaf(targetNode);
    } else {
      removeNonLeaf();
    } size--;
    reset();
  }

  public final void balance() {
    GC.disable();
    reset();
    listify(root);
    root = null;
    GC.enable();
    GC.collect();
    int temp = size;
    size = 0;
    bulkInsert(0, temp-1);
    transfer = null;
    GC.collect();
  }

  private final void reset() {
    targetNode = null;
    parent = null;
    found = false;
  }

  private final real cmp(T item) {
    static if (is(T == class)) {
      return cast(real) (cast(void*) item);
    } else {
      return cast(real) item;
    }
  }

  private final void addNode(T item, real val) {
    if(root is null) {
      root = new tree_node(item,val);
    } else if(val > targetNode.val) {
      targetNode.right = new tree_node(item,val);
    } else {
      targetNode.left = new tree_node(item,val);
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

  protected final tree_node * getNextLargest(tree_node * current) {
    while(!(current.left is null)) {
      parent = current;
      current = current.left;
    } return current;
  }

  protected final tree_node * getNextSmallest(tree_node * current) {
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
      if(!(replacement.right is null)) {
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

  private final void listify(tree_node * current) {
    if(current is null) { return; }
    listify(current.left);
    transfer ~= current.payload;
    listify(current.right);
  }

  private final void bulkInsert(int low, int high) {
    if(low > high) { return; }
    int midpoint = (low + high) >> 1;
    insert(transfer[midpoint]);
    bulkInsert(low, midpoint - 1);
    bulkInsert(midpoint+1, high);
  }
}

unittest {
  auto tree = new BST!int;
  for(int i = 1; i <= 10000; i++) {
    tree.insert(i);
    assert(tree.getSize() == i);
  }
  tree.balance();
  for(int j = 10001; j >= 0; j--) {
    tree.remove(j);
  }
  assert(tree.getSize() == 0);
}

unittest {
  auto tree = new BST!int;
  tree.insert(3);
  assert(tree.getSize() == 1);
  assert(tree.searchTree(3));
}

unittest {
  int newsize;
  auto tree = new BST!int;
  for(int i = 0; i < 10001; i++) {
    tree.insert(i);
    assert(tree.searchTree(i));
  }
  tree.balance();
  for(int i = 0; i < 10001; i++) {
    newsize = tree.getSize();
    tree.remove(i);
    newsize--;
    assert(!tree.searchTree(i));
    assert(newsize == tree.getSize());
  }
  assert(tree.getSize() == 0);

  for(int i = 10000; i >= 0; i--) {
    tree.insert(i);
    assert(tree.searchTree(i));
  }

  for(int i = 10000; i >= 0; i--) {
    newsize = tree.getSize();
    tree.remove(i);
    newsize--;
    assert(!tree.searchTree(i));
    assert(newsize == tree.getSize());
  }
  assert(tree.getSize() == 0);
}

unittest {
  int newsize;
  import std.random;
  auto tree = new BST!int;
  for(int i = 1; i <= 10; i++) {
    int rand = 0;
    for(int j = 0; j < 1000000; j++) {
      rand = uniform(-1000000, 1000000);
      tree.insert(rand);
      assert(tree.searchTree(rand));
    }

    for(int k = -1000001; k <= 1000001; k++) {
      newsize = tree.getSize();
      if(tree.searchTree(k)) {
        newsize--;
      }
      tree.remove(k);

      assert(!tree.searchTree(k));
      assert(newsize == tree.getSize());
    }
    assert(tree.getSize() == 0);
  }
}

unittest {
  class thingy {}
  import Stack: Stack;
  auto stack = new Stack!thingy;
  auto tree = new BST!thingy;

  for(int i = 0; i < 10000; i++) {
    auto thing = new thingy;
    stack.push(thing);
    tree.insert(thing);
    assert(tree.searchTree(thing));
  }
  tree.balance();
  for(int i = 0; i < 10000; i++) {
    auto thing = stack.pop();
    tree.remove(thing);
    assert(!tree.searchTree(thing));
  }
  assert(tree.getSize() == 0);
}

unittest {
  import std.random;
  import Stack: Stack;

  auto tree = new BST!int;
  auto stk = new Stack!int;
  int rand = 0;
  for(int j = 0; j < 1000000; j++) {
    rand = uniform(-1000000, 1000000);
    stk.push(rand);
    tree.insert(rand);
    assert(tree.searchTree(rand));
  }
  tree.balance();
  while(stk.length() > 0) {
    assert(tree.searchTree(stk.pop()));
  }



}
