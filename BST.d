import std.stdio: writeln;
import core.stdc.stdlib: exit;
import core.memory;


class BST(T) {

  private int size = 0;
  private tree_node * root = null;
  private tree_node * targetNode = null;
  private tree_node * balancePoint = null;
  private T[] transfer;
  private bool takeRight = false;

  private struct tree_node {
    T payload;
    real val = 0.0;
    tree_node*[3] C;
    int numDesc = 0;
  }

  public final int getSize() { return size; }

  public final bool search(T item) {
    return searchTree(cmp(item));
  }

  private final bool searchTree(real val) {
    if(root is null) { return false; }
    tree_node * current = root;
    while(current !is null) {
      if(unbalanced(current) && balancePoint is null) {
        balancePoint = current;
      } targetNode = current;
      if(current.val == val) { return true; }
      current = current.C[comp(current.val, val)];
    } return false;
  }

  private final int comp(real cur, real input) {
    if(cur > input) { return 0; }
    return 2;
  }

  public final void insert(T item) {
    if(searchTree(cmp(item))) { return; }
    tree_node * A = new tree_node(item,cmp(item));
    if(root is null) {
      root = A;
      A.C[1] = root;
    } else {
      A.C[1] = targetNode;
      targetNode.C[comp(targetNode.val, cmp(item))] = A;
      descMod(targetNode, 1);
    } size++;
    if(balancePoint !is null) {
      balance(balancePoint);
    }
  }

  public final void remove(T item) {
    if(!searchTree(cmp(item))) { return; }
    if((cmp(item) == root.val) && isLeaf(root)) {
      root = null;
    } else if(isLeaf(targetNode)) {
      targetNode = targetNode.C[1];
      targetNode.C[comp(targetNode.val, cmp(item))] = null;
      descMod(targetNode, -1);
    } else {
      swap(detach(), targetNode);
      descMod(targetNode, -1);
    } size--;
    if(balancePoint !is null) {
      balance(balancePoint);
    }
  }

  private final tree_node* detach() {
    tree_node*swap;
    if(takeRight || targetNode.C[0] is null) {
      swap = getNext(targetNode.C[2], 0);
    } else {
      swap = getNext(targetNode.C[0], 2);
    } int dir = comp(swap.C[1].val, swap.val);
    if(swap.C[1] is targetNode) {
      swap = linkNext(swap, dir);
    } else if(isLeaf(swap)) {
      tree_node* temp = swap.C[1];
      temp.C[dir] = null;
    } else {
      swap.C[2-dir].C[1] = swap.C[1];
      swap.C[1].C[dir] = swap.C[2-dir];
    } return swap;
  }

  private final tree_node* linkNext(tree_node * swap, int dir) {
    targetNode.C[dir] = swap.C[dir];
    if(targetNode.C[dir] !is null) {
      targetNode.C[dir].C[1] = targetNode;
    } return swap;
  }

  private final void swap(tree_node * current, tree_node * other) {
    T temp = other.payload;
    real tempVal = other.val;
    int tempDesc = other.numDesc;
    other.val = current.val;
    other.payload = current.payload;
    other.numDesc = current.numDesc;
    current.val = tempVal;
    current.payload = temp;
    current.numDesc = tempDesc;
  }

  private final real cmp(T item) {
    static if (is(T == class)) {
      return cast(real) (cast(void*) item);
    } else {
      return cast(real) item;
    }
  }

  private final bool isLeaf(tree_node * current) {
    return ((current.C[0] is null) && (current.C[2] is null));
  }

  private final tree_node * getNext(tree_node * current, int next) {
    while(!(current.C[next] is null)) {
      current = current.C[next];
    } return current;
  }

  private final void descMod(tree_node * current, int modNum) {
    current.numDesc += modNum;
    do {
      current = current.C[1];
      current.numDesc += modNum;
    } while(current !is root);
  }

  private final bool unbalanced(tree_node * current) {
    if(current.C[0] is null || current.C[2] is null) { return false; }
    return (current.C[0].numDesc > 2*current.C[2].numDesc) ||
           (current.C[2].numDesc > 2*current.C[0].numDesc);
  }

  public final void rebalance() {
    if(size < 7) { return; }
    balance(root);
  }

  private final void balance(tree_node * current) {
    takeRight = (current.C[2].numDesc > current.C[0].numDesc);
    tree_node * swap1, swap2;
    targetNode = current;
    while(unbalanced(current)) {
      swap = detach();
      swap(&*current, &*swap);
      if(takeRight) {
        swap2 = getNext(current, 2);
        swap2.C[2] = swap;
      } else {
        swap2 = getNext(current, 0);
        swap2.C[1] = swap;
      } swap.C[1] = swap2;
      descMod(swap2);
    }

  }

}




unittest {
  auto tree = new BST!int;
  tree.insert(3);
  assert(tree.getSize() == 1);
  assert(tree.search(3));
}

unittest {
  auto tree = new BST!int;
  for(int i = 1; i <= 1000; i++) {
    tree.insert(i);
    assert(tree.getSize() == i);
    tree.insert(i);
    assert(tree.getSize() == i);
    assert(tree.search(i));
  }
}

unittest {
  auto tree = new BST!int;
  for(int i = 1000; i > 0; i--) {
    tree.insert(i);
    assert(tree.getSize() == 1000 - i + 1);
    assert(tree.search(i));
  }
}

unittest {
  auto tree = new BST!int;
  import std.random;
  int rand;
  for(int j = 0; j < 1000; j++) {
    rand = uniform(-1000000, 1000000);
    tree.insert(rand);
    assert(tree.search(rand));
  }
}

unittest {
  auto tree = new BST!int;
  for(int i = 0; i < 1001; i++) {
    tree.insert(i);
    assert(tree.search(i));
  }
  assert(tree.search(500));
  for(int i = 0; i < 1001; i++) {
    tree.remove(i);
    assert(!tree.search(i));
  }
  assert(tree.getSize() == 0);
}

unittest {
  auto tree = new BST!int;
  for(int i = 10000; i >= 0; i--) {
    tree.insert(i);
    assert(tree.search(i));
  } int newsize;
  for(int i = 10000; i >= 0; i--) {
    newsize = tree.getSize();
    tree.remove(i);
    newsize--;
    assert(!tree.search(i));
    assert(newsize == tree.getSize());
  }
  assert(tree.getSize() == 0);
}

unittest {
  auto tree = new BST!int;
  tree.insert(0);
  //tree.insert(-100);
  tree.insert(100);
  tree.insert(75);
  tree.insert(80);
  tree.insert(40);
  tree.insert(45);
  tree.insert(41);
  tree.insert(46);

  tree.remove(46);
  assert(!tree.search(46));
  tree.insert(46);

  assert(tree.search(40));
  tree.remove(40);
  assert(tree.search(46));
  assert(!tree.search(40));
}




unittest {
  import std.random;
  auto tree = new BST!int;
  for(int i = 1; i <= 10; i++) {
    int rand = 0;
    for(int j = 0; j < 10000; j++) {
      rand = uniform(-10000, 10000);
      tree.insert(rand);
      assert(tree.search(rand));
    }
    int newsize;
    for(int k = -10001; k <= 10001; k++) {
      newsize = tree.getSize();
      if(tree.search(k)) {
        newsize--;
      } tree.remove(k);
      assert(!tree.search(k));
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
    assert(tree.search(thing));
  }
  //tree.balance();
  for(int i = 0; i < 10000; i++) {
    auto thing = stack.pop();
    tree.remove(thing);
    assert(!tree.search(thing));
  }
  assert(tree.getSize() == 0);
}
/*
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
*/
