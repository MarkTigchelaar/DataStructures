import std.stdio: writeln, write;
import core.stdc.stdlib: exit;
import core.memory;
import std.math: abs;


class BST(T) {

  private ulong size = 0;
  private uint stackSize = 0;
  private tree_node * root = null;
  private tree_node * targetNode = null;
  //private tree_node * stackRoot = null;
  private bool rotateLeft = false;

  private struct tree_node {
    T payload;
    long val = 0;
    tree_node*[3] C;
    long numDesc = 0;
  }

  public final ulong getSize() {
    return size;
  }

  public final bool search(T item) {
    return searchTree(cmp(item));
  }

  public final void printOut() {
    writeln();
    traverse(&*root);
  }

  public final void rebalance() {
    findUnbalanced(&*root);
  }

  public final void insert(T item) {
    if(searchTree(cmp(item))) { return; }
    tree_node * A = new tree_node(item,cmp(item));
    if(root is null) {
      A.numDesc = 1;
      root = A;
      A.C[1] = root;
    } else {
      A.C[1] = targetNode;
      targetNode.C[comp(targetNode.val, cmp(item))] = A;
      descMod(A, 1);
    } size++;
  }

  public final void remove(T item) {
    if(!searchTree(cmp(item))) { return; }
    tree_node * toStack;
    if((cmp(item) == root.val) && isLeaf(root)) {
      toStack = root;
      root = null;
    } else if(isLeaf(&*targetNode)) {
      descMod(&*targetNode, -1);
      toStack = targetNode;    
      targetNode = targetNode.C[1];
      targetNode.C[comp(targetNode.val, cmp(item))] = null;
    } else {
      descMod(&*targetNode, -1);
      toStack = detatch(&*targetNode);
      swap(&*toStack, &*targetNode);      
    } size--;
    //sendToStack(toStack);
  }

  private final bool searchTree(long val) {
    if(root is null) { return false; }
    tree_node * current = root;
    while(current !is null) {
      targetNode = current;
      if(current.val == val) { return true; }
      current = current.C[comp(current.val, val)];
    } return false;
  }

  private final int comp(long cur, long input) {
    if(cur > input) { return 0; }
    return 2;
  }

  private final tree_node* detatch(tree_node* tNode) {
    tree_node*swap;
    if(rotateLeft|| tNode.C[0] is null) {
      swap = getNext(tNode.C[2], 0);
    } else {
      swap = getNext(tNode.C[0], 2);
    } int dir = comp(swap.C[1].val, swap.val);
    if(swap.C[1] is tNode) {
      swap = linkNext(&*swap, dir, &*tNode);
    } else if(isLeaf(swap)) {
      tree_node* temp = swap.C[1];
      temp.C[dir] = null;
    } else {
      swap.C[2-dir].C[1] = swap.C[1];
      swap.C[1].C[dir] = swap.C[2-dir];
    } return swap;
  }

  private final tree_node* linkNext(
      tree_node * swap, int dir, tree_node* tNode) {
    tNode.C[dir] = swap.C[dir];
    if(tNode.C[dir] !is null) {
      tNode.C[dir].C[1] = tNode;
    } return swap;
  }

  private final void swap(
      tree_node * current, tree_node * other) {
    T temp = other.payload;
    long tempVal = other.val;
    long tempDesc = other.numDesc;
    other.val = current.val;
    other.payload = current.payload;
    other.numDesc = current.numDesc;
    current.val = tempVal;
    current.payload = temp;
    current.numDesc = tempDesc;
  }

  private final long cmp(T item) {
    static if (is(T == class)) {
      return cast(long) (cast(void*) item);
    } else {
      return cast(long) item;
    }
  }

  private final bool isLeaf(tree_node * current) {
    return ((current.C[0] is null) &&
      (current.C[2] is null));
  }

  private final tree_node * getNext(
      tree_node * current, int next) {
    while(!(current.C[next] is null)) {
      current = current.C[next];
    } return current;
  }

  private final void descMod(
      tree_node * current, long modNum) {
    while(current !is root) {    
      current.numDesc += modNum;
      current = current.C[1];
    } current.numDesc += modNum;
  }

  private final bool unbalanced(tree_node * current) {
    if(current.C[0] is null && current.C[2] is null) {
      return false;
    } else if(current.C[0] is null || current.C[2] is null) {
      return true;
    } return (current.C[0].numDesc > 2*current.C[2].numDesc) ||
           (current.C[2].numDesc > 2*current.C[0].numDesc);
  }

  private final void determineUnbalancedSide(tree_node * current) {
    if(current.C[0] is null) {
      rotateLeft = true;
    } else if(current.C[2] is null) {
      rotateLeft = false;
    } else {
      rotateLeft =  current.C[0].numDesc < current.C[2].numDesc;      
    }
  }

  private final void findUnbalanced(tree_node * current) {
    if(current is null) {
      return;
    } else if(unbalanced(&*current)) {// put if in here for size boundaries. Small trees use custom expression. Mid - large: balance(), larger: moveTrees()
      balance(&*current);
      return;
    } findUnbalanced(current.C[0]);
    findUnbalanced(current.C[2]);
  }

  private final void balance(tree_node * current) {
    if(current is null) { return; }
    determineUnbalancedSide(&*current);
    long redistribute = getAmount(&*current);// current.numDesc / 2;
    for(long i = 0; i < redistribute; i++) {
      tree_node * change = detatch(&*current);
      descMod(&*change, -1);
      swap(&*change, &*current);
      current.numDesc = change.numDesc;
      size--;
      insert(change.payload);
      //sendToStack(&*change);
    } rotateLeft = false;
    balance(current.C[0]);
    balance(current.C[2]);
  }

  private final long getAmount(tree_node * current) {
    if(current.C[0] is null && current.C[2] is null) {
      return 0;
    } else if(current.C[0] is null) {
      return current.C[2].numDesc / 2;
    } else if(current.C[2] is null) {
      return current.C[0].numDesc / 2;
    } else {
      return abs(current.C[0].numDesc - current.C[2].numDesc) / 2;
    }
  }

  private final void traverse(tree_node * current) {
    if(current is null) { return; }
    traverse(current.C[0]); 
    contour(current.numDesc);
    write(current.payload);
    if(current == root) { write(" root"); }
    write(", nodes in tree: ");
    writeln(current.numDesc);
    traverse(current.C[2]);
  }

  private final void contour(long levels) {
    for(long i = 1; i < levels; i++) {
      write("-");
    }
  }
}


unittest {
  auto tree = new BST!int;
  tree.insert(1);
  tree.insert(2);
  tree.insert(3);
  tree.insert(4);
  tree.printOut();
  tree.rebalance();
  tree.printOut();
  tree.insert(5);
  tree.insert(6);
  tree.rebalance();
  tree.printOut();
  tree.insert(7);
  tree.insert(8);
  tree.insert(9);
  tree.insert(10);
  tree.rebalance();
  tree.printOut();
}


unittest {
  auto tree = new BST!int;
  tree.insert(3);
  assert(tree.getSize() == 1);
  assert(tree.search(3));
  tree.insert(4);
  tree.insert(5);
  tree.insert(6);
  tree.insert(7);
  tree.insert(8);
  tree.insert(9);
  tree.rebalance();
  assert(tree.getSize() == 7);
}

unittest {
  auto tree = new BST!int;
  for(int i = 1; i <= 100; i++) {
    tree.insert(i);
    assert(tree.getSize() == i);
    tree.insert(i);
    assert(tree.getSize() == i);
    assert(tree.search(i));
    tree.rebalance();
  } tree.insert(101);
  
  tree.printOut();  
}

unittest {
  auto tree = new BST!int;
  for(int i = 1000; i > 0; i--) {
    tree.insert(i);
    assert(tree.getSize() == 1000 - i + 1);
    assert(tree.search(i));
  } tree.rebalance();
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
  } long newsize;
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
    long newsize;
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
  writeln("Rebalancing 1");
  tree.rebalance();
  writeln("Balanced. 1");
  for(int i = 0; i < 10000; i++) {
    auto thing = stack.pop();
    tree.remove(thing);
    assert(!tree.search(thing));
  }
  assert(tree.getSize() == 0);
}

unittest {
  import std.random;
  import Stack: Stack;

  auto tree = new BST!int;
  auto stk = new Stack!int;
  int rand = 0;
  for(int j = 0; j < 20000; j++) {
    rand = uniform(-1000000, 1000000);
    stk.push(rand);
    tree.insert(rand);
    assert(tree.searchTree(rand));
  }
  writeln("Rebalancing 2");
  tree.rebalance();
  writeln("Balanced. 2");
  while(stk.length() > 0) {
    assert(tree.searchTree(stk.pop()));
  }
}

