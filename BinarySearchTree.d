class BinarySearchTree(T) {
  import commonTypes;
  import Stack: Stack;

  private node!T* root = null;
  private node!T* head = null;
  private Stack!T stack;

  private immutable int left = 0;
  private immutable int right = 1;
  private immutable int up = 2;

  this() {
    stack = new Stack!T;
  }

  public long getSize() {
    if(root !is null) {
      return root.size;
    } return 0;
  	
  }

  public void insert(T[] items...) {
    foreach(item; items) {
      head = null;
      if(add(New(item))) {
        balanceTree(head);
      }
    } head = null;
  }

  public void remove(T[] items...) {
    bool bal = false;
    foreach(item; items) {
      head = null;
      returnToStack(takeNode(New(item), &bal));
      if(bal) {
        bal = false;
        balanceTree(head);
      }
    } head = null;
  }

  public T[] popItemsByKeys(long[] keys...) {
    bool bal = false;
    T[] items;
    node!T* current;
    foreach(key; keys) {
      current = New(cast(T) null);
      current.val = key;
      current = takeNode(current, &bal);
      if(current !is null) {
        items ~= current.payload;
        returnToStack(current);
      } if(bal) {
        bal = false;
        balanceTree(head);
      }
    } return items;
  }

  public bool isItemInTree(T item) {
    node!T* current = root;
    node!T* temp = New(item);
    int index;
    while(current !is null) {
      if(current.val == temp.val) {
        returnToStack(temp);
        return true;
      }
      index = direction(current, temp);
      current = nextNode(current, index);
    }
    returnToStack(temp);
    return false;
  }

  public void balance() {
    listify(root);
    root = null;
    root = rebuildTree(head,right);
    head = null;
  }

  public void clear() {
    root = null;
    head = null;
    stack = null;
  }

  private node!T* New(T item) {
    node!T* retVal;
    if(! stack.isEmpty()) {
      retVal = stack.pop();
      clearNode(retVal);
    } else {
      retVal = new node!T();
    }
    retVal.payload = item;
    retVal.val = cmpVal(item);
    return retVal;
  }

  private void returnToStack(node!T* treeNode) {
    if(treeNode is null) { return; }
    clearNode(treeNode);
    treeNode.payload = cast(T) null;
    stack.push(treeNode);
  }

  private void clearNode(node!T* treeNode) {
    treeNode.nodes[left] = null;
    treeNode.nodes[right] = null;
    treeNode.nodes[up] = null;
    treeNode.size = 0;
  }

  private final long cmpVal(T item) {
    static if (is(T == class)) {
      return cast(long) (cast(void*) item);
    } else static if(is(T == NetworkNode)) {
      return item.compareFunction();
    } else {
      return cast(long) item;
    }
  }

  private bool add(node!T* treeNode) {
    if(root is null) {
      root = treeNode;
      root.size = 1;
      return false;
    }
    int index;
    node!T* current = root;
    bool balance = false;
    while(current !is null) {
      index = direction(current, treeNode);
      setForBalance(current, &balance);
      if(spotFound(current,treeNode,index)) {
      	break;
      } current = nextNode(current, index);  
    } return balance;
  }

  private void setForBalance(node!T* current,bool* balance) {
  	if(!*balance && unbalanced(current)) {
        *balance = true;
        head = current;
    }
  }

  private bool spotFound(
  	    node!T* current,
  	    node!T* treeNode,
  	    int index
  	) {
    if(current.val == treeNode.val) {
      returnToStack(treeNode);
      return true;
    } if(nextIsNull(current,index)) {
      attachChildToParent(current,treeNode,index);
      modifySize(treeNode,1);
      return true;
    } return false;
  }

  private node!T* takeNode(node!T* comp, bool* balance) {
    node!T* current = root;
    int index;
    while(current !is null) {
      index = direction(current, comp);
      setForBalance(current, balance);
      if(current.val == comp.val) {
        returnToStack(comp);
        return removeNode(current);
      } current = nextNode(current, index);
    } returnToStack(comp);
    return null;
  }

  private node!T* removeNode(node!T* current) {
    if(current is root) {
      return removeRoot(current);
    } else if(isLeaf(current)) {
      modifySize(current, -1);
      return takeLeaf(current);
    } else if(inList(current)) {
      return takeFromList(current);
    } else {
      return takeSubTreeNode(current);
    }
  }

  private node!T* removeRoot(node!T* treeRoot) {
    if(treeRoot.size == 1) {
      returnToStack(root);
      root = null;
      return null;
    } return takeSubTreeNode(treeRoot);
  }

  private int nonNullDirection(node!T* treeNode) {
    return cast(int) nextIsNull(treeNode, left);
  }

  private bool isLeaf(node!T* current) {
    return ((current.nodes[left] is null) &&
      (current.nodes[right] is null));
  }

  private node!T* takeLeaf(node!T* current) {
    node!T* parentNode = parent(current);
    int dir = direction(parentNode,current);
    parentNode.nodes[dir] = null;
    current.nodes[up] = null;
    return current;
  }

  private bool inList(node!T* current) {
    return ((current.nodes[left] is null) ||
      (current.nodes[right] is null)) &&
      current.nodes[up] !is null;
  }

  private node!T* takeFromList(node!T* current) {
    node!T* parentNode = parent(current);
    int nonNullDir = nonNullDirection(current);
    int dir = direction(parentNode,current);

    parentNode.nodes[dir] = current.nodes[nonNullDir];
    parentNode.nodes[dir].nodes[up] = parentNode;

    modifySize(current, -1);

    current.nodes[up] = null;
    current.nodes[dir] = null;
    return current;
  }

  private node!T* takeSubTreeNode(node!T* current) {
    node!T* leaf;
    int dir = cast(int) nextIsNull(current,right);
    leaf = takeLowestNode(nextNode(current,1 - dir), dir);
    swapValues(current, leaf);
    return leaf;
  }

  private node!T* takeLowestNode(node!T* treeNode, int dir) {
    while(!nextIsNull(treeNode,dir)) {
      treeNode = nextNode(treeNode, dir);
    } if(isLeaf(treeNode)) {
      modifySize(treeNode, -1);
      return takeLeaf(treeNode);
    } return takeFromList(treeNode);
  }

  private void swapValues(node!T* current,node!T* leaf) {
    T temp = leaf.payload;
    long tempVal = leaf.val;
    leaf.val = current.val;
    leaf.payload = current.payload;
    leaf.size = current.size;
    current.val = tempVal;
    current.payload = temp;
  }

  private void attachChildToParent(
  	  node!T* current,
  	  node!T* treeNode,
  	  int index
  	  ) {
    current.nodes[index] = treeNode;
    if(current.nodes[index] !is null) {
      current.nodes[index].nodes[up] = current;
    }
  }

  private node!T* nextNode(node!T* treeNode, int index) {
    return treeNode.nodes[index];
  }

  private bool nextIsNull(node!T* current, long val) {
    return current.nodes[val] is null;
  }

  private int direction(node!T* current,node!T* treeNode) {
    return cast(int) (current.val < treeNode.val);
  }

  private void modifySize(node!T* treeNode, int addOrSub) {
    while(treeNode !is root) {
      treeNode.size += addOrSub;
      treeNode = parent(treeNode);
    } root.size += addOrSub;
  }

  private node!T* parent(node!T* treeNode) {
    return treeNode.nodes[up];
  }

  private bool unbalanced(node!T* treeNode) {
    if(treeNode.size < 3) { return false; }

    if(nextIsNull(treeNode,left) ||
      nextIsNull(treeNode,right)) {
      return true;
    }
    long leftSize = treeNode.nodes[left].size;
    long rightSize = treeNode.nodes[right].size;
    return leftSize > 2*rightSize ||
           rightSize > 2*leftSize;
  }

  private void balanceTree(node!T* treeNode) {
    if(treeNode is root) {
      head = null;
      balance();
      return;
    }
    node!T* parent = parent(treeNode);
    int index = direction(parent, treeNode);
    detachParentFromChild(parent, index);
    head = null;
    listify(treeNode);
    attachChildToParent(parent, rebuildTree(head,right), index);
  }

  private void detachParentFromChild(
  	    node!T* treeNode, int direction) {
    if(treeNode.nodes[direction] !is null) {
      treeNode.nodes[direction].nodes[up] = null;
    } treeNode.nodes[direction] = null;
  }

  private void listify(node!T* treeNode) {
    if(treeNode is null) { return; }

    node!T* LHS = treeNode.nodes[left];
    node!T* RHS = treeNode.nodes[right];
    clearNode(treeNode);

    listify(LHS);

    if(head is null) {
      head = treeNode;
      head.size = 1;
    } else {
      treeNode.nodes[left] = head;
      treeNode.size = head.size + 1;
      head.nodes[up] = treeNode;
      head = treeNode;
    }

    listify(RHS);
  }

  private node!T* rebuildTree(node!T* treeNode,int nodesIdx) {
    if(treeNode is null) { return null; }
    long half = treeNode.size /2;
    
    for(int i; i < half; i++) {
      treeNode = rotateList(treeNode,nodesIdx);
    }
	moveSubTreeRoot(treeNode, nodesIdx);
	moveSubTreeRoot(treeNode, 1 - nodesIdx);
    return treeNode;
  }

  private void moveSubTreeRoot(node!T* treeNode, int direction) {
    node!T* temp = treeNode.nodes[1-direction];
    detachParentFromChild(treeNode,1-direction);
    attachChildToParent(treeNode, rebuildTree(temp, direction), 1-direction);
  }

  private node!T* rotateList(node!T* listNode,int index) {
    int addTo = 1;
    if(! nextIsNull(listNode, index)) {
      addTo += listNode.nodes[index].size;
    }
    node!T* temp = nextNode(listNode,1-index);

    promoteChild(temp, index);
    temp.size += addTo;

    demoteParent(listNode,1-index);
    listNode.size = addTo;

    return temp;
  }

  private void promoteChild(node!T* listNode,int index) {
    listNode.nodes[index] = listNode.nodes[up];
    listNode.nodes[up] = null;
  }

  private void demoteParent(node!T* listNode,int index) {
    listNode.nodes[up] = listNode.nodes[index];
    listNode.nodes[index] = null;
  }

  public void printOut() {
    import std.stdio: writeln;
    traverse(root);
    writeln("\n");
  }

  private final void traverse(node!T* current) {
    import std.stdio: writeln, write;
    if(current is null) { return; }
    traverse(current.nodes[left]); 
    contour(current.size);
    
    if(current == root) { write("root "); }
    static if(is(current.payload == class)) {
      write("Class");
    } else {
      write(current.val);
    }
    write(", nodes: ");
    writeln(current.size);
    traverse(current.nodes[right]);
  }

  private final void contour(long levels) {
    import std.stdio: write;
    for(long i = 1; i < levels; i++) {
      write("-");
    }
  }

  // ---------Testing Code------------
  private int testSize() {
    return counter(root, 0);
  }

  private int counter(node!T* treeNode, int target) {
    import std.stdio: writeln;
    if(treeNode is null) { return 0; }
    target += counter(treeNode.nodes[left], 0);
    target += counter(treeNode.nodes[right], 0);

    target++;
    if(target != treeNode.size) {
      writeln("ERROR: treeCount inaccurate, 
      reported ", treeNode.size, " but is ", target);
      return 0;
    }
    return target;
  }
}


// getSize() accurately reports tree size
// All nodes have accurate count of sub tree size
// even after rebalancing, deletion, and more rebalancing
unittest {
  auto Tree = new BinarySearchTree!int;
  for(int i=0; i<50; i++) {
    Tree.insert(i);
  }
  assert(Tree.getSize() == Tree.testSize());
  for(int j=30; j< 48; j++) {
    Tree.remove(j);
  }
  assert(Tree.getSize() == Tree.testSize());
  Tree.balance();
  assert(Tree.getSize() == Tree.testSize());
}

// Allow user to get size of null tree
unittest {
  auto Tree = new BinarySearchTree!long;
  assert(Tree.getSize() == 0);
}

// Prevent double insertions
unittest {
  auto Tree = new BinarySearchTree!int;
  Tree.insert(1);
  assert(Tree.getSize() == 1);
  Tree.insert(1);
  assert(Tree.getSize() == 1);
}

// Ignore the removal of non tree members
unittest {
  auto Tree = new BinarySearchTree!long;
  Tree.insert(1);
  Tree.remove(2);
  assert(Tree.getSize() == 1);
}

// Allow removal of root nodes
unittest {
  auto Tree = new BinarySearchTree!double;
  Tree.insert(1.0);
  Tree.insert(0.0);
  Tree.insert(2.0);
  assert(Tree.getSize() == 3);
  Tree.remove(1);
  assert(Tree.getSize() == 2);
}

// Allow removal of leaf nodes
unittest {
  auto Tree = new BinarySearchTree!real;
  Tree.insert(1.0);
  Tree.insert(2.0);
  assert(Tree.getSize() == 2);
  Tree.remove(2.0);
  assert(Tree.getSize() == 1);
}

// Allow removal of nodes with a parent, and one child
// straight list like
unittest {
  auto Tree = new BinarySearchTree!double;
  Tree.insert(1.0);
  Tree.insert(0.0);
  Tree.insert(2.0);
  Tree.insert(3.0);
  assert(Tree.getSize() == 4);
  Tree.remove(2.0);
  assert(Tree.getSize() == 3);
}

// dog leg
unittest {
  auto Tree = new BinarySearchTree!char;
  Tree.insert('f');
  Tree.insert('e');
  Tree.insert('h');
  Tree.insert('d');
  Tree.insert('g');
  assert(Tree.getSize() == 5);
  Tree.remove('h');
  assert(Tree.getSize() == 4);  
}

// Allow removal of nodes with parent, and two children
unittest {
  auto Tree = new BinarySearchTree!double;
  Tree.insert(0.0);
  Tree.insert(-2.0);
  Tree.insert(2.0);
  Tree.insert(-3.0);
  Tree.insert(3.0);
  Tree.insert(-1.0);
  Tree.insert(1.0);
  assert(Tree.getSize() == 7);
  Tree.remove(2.0);
  assert(Tree.getSize() == 6);
}

// Allow items to be taken if key is available
// TODO
// Will use interface method for classes for key gen
unittest {
  import std.stdio: writeln;
  class Test{
    private int t;
    this() {
      t = 1;
    }
  }
  auto Tree = new BinarySearchTree!Test;
  Test[] tests;
  long[] keys;
  for(int i=0; i< 10; i++) {
    auto t = new Test();
    keys ~= cast(long) (cast(void*) t);
    Tree.insert(t);
    assert(Tree.isItemInTree(t));
    assert(cast(int) Tree.getSize() == Tree.testSize());
  }
  writeln(Tree.getSize());
  tests = Tree.popItemsByKeys(keys);
    
  
  writeln(tests.length);
  //assert(tests.length == 10);

}

unittest {
  import std.stdio: writeln;
  import commonTypes: NetworkNode;
  class Test: NetworkNode {
    private char ch;
    private NetworkNode[] Observers;
    this(char ch) {
      ch = ch;
    }

    long compareFunction() {
      return cast(long) ch;
    }

    void subscribe(NetworkNode[] newObservers) {
      Observers = newObservers;
    }

    void unsubscribe(NetworkNode[] oldObservers) {
      Observers = null;
    }

    string getKey() {
      return "String!";
    }
  }

  auto Tree = new BinarySearchTree!Test;
  char a = 'a';
  Test[] tests;
  long[] keys;
  for(int i=0; i< 10; i++) {
    auto t = new Test(a);
    a++;
    keys ~= cast(long) (cast(void*) t);
    Tree.insert(t);
    assert(Tree.isItemInTree(t));
  }
  writeln(Tree.getSize());  


}