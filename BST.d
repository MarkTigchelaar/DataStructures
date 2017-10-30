import std.stdio: writeln, write;
import core.stdc.stdlib: exit;
import core.memory;
import std.math: abs;


class BST(T) {

  private ulong size = 0;
  private uint stackSize = 0;
  private tree_node * root = null;
  private tree_node * targetNode = null;
  private bool rotateLeft = false;
  private tree_node * head = null;

  private struct tree_node {
    T payload;
    ulong val = 0;
    tree_node*[3] C;
    ulong numDesc = 0;
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
  }

  public void balance() {
	if(size <2) { return; }
	head = null;
	listify(root);
	root = null;
	root = head;
	root = makeTree(size);
	root.C[1] = root;
	head = null;
	populate(root);	
  }

  private final bool searchTree(ulong val) {
    if(root is null) { return false; }
    tree_node * current = root;
    while(current !is null) {
      targetNode = current;
      if(current.val == val) { return true; }
      current = current.C[comp(current.val, val)];
    } return false;
  }

  private final int comp(ulong cur, ulong input) {
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

  private final tree_node * linkNext(
    	tree_node * swap,
    	int dir,
    	tree_node* tNode
    ) {
    tNode.C[dir] = swap.C[dir];
    if(tNode.C[dir] !is null) {
      tNode.C[dir].C[1] = tNode;
    } return swap;
  }

  private final void swap(
      tree_node * current,
      tree_node * other
    ) {
    T temp = other.payload;
    ulong tempVal = other.val;
    ulong tempDesc = other.numDesc;
    other.val = current.val;
    other.payload = current.payload;
    other.numDesc = current.numDesc;
    current.val = tempVal;
    current.payload = temp;
    current.numDesc = tempDesc;
  }

  private final ulong cmp(T item) {
    static if (is(T == class)) {
      return cast(ulong) (cast(void*) item);
    } else {
      return cast(ulong) item;// Add another option if T is a interface (define it above)
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
      tree_node * current, ulong modNum) {
    while(current !is root) {    
      current.numDesc += modNum;
      current = current.C[1];
    } current.numDesc += modNum;
  }

  private final void traverse(tree_node * current) {
    if(current is null) { return; }
    traverse(current.C[0]); 
    contour(current.numDesc);
    
    if(current == root || current == head) { write("root "); }
    write(current.payload);
    write(", nodes: ");
    writeln(current.numDesc);
    traverse(current.C[2]);
  }

  private final void contour(ulong levels) {
    for(ulong i = 1; i < levels; i++) {
      write("-");
    }
  }

  private void listify(tree_node * node) {
	if(node is null) { return; }

	tree_node * RHS = node.C[2];
	tree_node * LHS = node.C[0];

	node.C[0] = null;
	node.C[1] = null;
	node.C[2] = null;

	node.numDesc = 0;

	listify(RHS);

	if(head is null) {
		head = node;
	} else {
		node.C[2] = head;
		head.C[0] = node;
		head = node;
	}

	listify(LHS);
  }

  private tree_node * makeTree(ulong nodes) {
	if(nodes <= 0) { return null; }
	tree_node * left = makeTree(nodes/2);
	tree_node * treeRoot = head;
	treeRoot.C[0] = left;
	head = head.C[2];
	treeRoot.C[2] = makeTree(nodes -1 -(nodes/2));
	return treeRoot;
  }

  private ulong populate(tree_node * node) {
	if(node is null) { return 0; }
	node.numDesc += populate(node.C[0]);
	node.numDesc += populate(node.C[2]);
	node.numDesc += 1;
	return node.numDesc;
  }
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
  } tree.insert(101);
  
  tree.printOut();  
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
  } ulong newsize;
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
    ulong newsize;
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
  while(stk.length() > 0) {
    assert(tree.searchTree(stk.pop()));
  }
}

