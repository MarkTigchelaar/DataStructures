import std.stdio: writeln, write;

class BinarySearchTree(T) {

  private struct node {
    T payload;
    long val = 0;
    node*[3] nodes;
    long treeSize = 0;
  }

  private node* root = null;
  private node* head = null;
  private node* stack = null;

  private immutable int left = 0;
  private immutable int right = 1;
  private immutable int up = 2;

  public long getSize() {
    if(root !is null) {
      return root.treeSize;
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
    node* current;
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
    node* current = root;
    node* temp = New(item);
    int idx;
    while(current !is null) {
      if(current.val == temp.val) {
        returnToStack(temp);
        return true;
      }
      idx = direction(current, temp);
      current = nextNode(current, idx);
    }
    returnToStack(temp);
    return false;
  }

  public void balance() {
    listify(root);
    root = null;
    root = rebuild(head,right);
    head = null;
  }

  private node* New(T item) {
    if(stack is null) {
      return new node(item,cmpVal(item));
    }
    node* retVal = stack;
    stack = stack.nodes[up];

    clearNode(retVal);
    retVal.payload = item;
    retVal.val = cmpVal(item);
    return retVal;
  }

  private final long cmpVal(T item) {
    static if (is(T == class)) {
      return cast(long) (cast(void*) item);
    } else {
      return cast(long) item;
    }
  }

  private bool add(node* nde) {
    if(root is null) {
      root = nde;
      root.treeSize = 1;
      return false;
    }

    int idx;
    node* current = root;
    bool balance = false;
    while(current !is null) {
      idx = direction(current, nde);
      if(!balance && unbalanced(current)) {
        balance = true;
        head = current;
      }
      if(current.val == nde.val) {
        returnToStack(nde);
        break;
      } else if(nextIsNull(current,idx)) {
        attachChild(current,nde,idx);
        modifyTreeSize(nde,1);
        break;
      } else {
        current = nextNode(current, idx);
      }
    }
    return balance;
  }

  private node* takeNode(node* comp, bool* balance) {
    node* current = root;
    int idx;
    while(current !is null) {
      idx = direction(current, comp);
      if(current.val == comp.val) {
        returnToStack(comp);
        return removeNode(current);
      } else if(!*balance && unbalanced(current)) {
        *balance = true;
        head = current;
      } else {
        current = nextNode(current, idx);
      }
    }
    returnToStack(comp);
    return null;
  }

  private node* removeNode(node* current) {
    if(current is root) {
      return removeRoot(current);
    } else if(isLeaf(current)) {
      modifyTreeSize(current, -1);
      return takeLeaf(current);
    } else if(inList(current)) {
      return takeFromList(current);
    } else {
      return takeSubTreeNode(current);
    }
  }

  private node* removeRoot(node * treeRoot) {
    if(treeRoot.treeSize == 1) {
      returnToStack(root);
      root = null;
      return null;
    } return takeSubTreeNode(treeRoot);
  }

  private int nonNullDirection(node* nde) {
    return cast(int) nextIsNull(nde, left);
  }

  private bool isLeaf(node * current) {
    return ((current.nodes[left] is null) &&
      (current.nodes[right] is null));
  }

  private node* takeLeaf(node * current) {
    node* parentNode = parent(current);
    int dir = direction(parentNode,current);
    parentNode.nodes[dir] = null;
    current.nodes[up] = null;
    return current;
  }

  private bool inList(node * current) {
    return ((current.nodes[left] is null) ||
      (current.nodes[right] is null)) &&
      current.nodes[up] !is null;
  }

  private node* takeFromList(node * current) {
    node* parentNode = parent(current);
    int nonNullDir = nonNullDirection(current);
    int dir = direction(parentNode,current);

    parentNode.nodes[dir] = current.nodes[nonNullDir];
    parentNode.nodes[dir].nodes[up] = parentNode;

    modifyTreeSize(current, -1);

    current.nodes[up] = null;
    current.nodes[dir] = null;
    return current;
  }

  private node* takeSubTreeNode(node * current) {
    node* leaf;
    if(!nextIsNull(current,right)) {
      leaf = takeLowestNode(nextNode(current,right), left);
    } else {
      leaf = takeLowestNode(nextNode(current,left), right);
    } swapValues(current, leaf);
    return leaf;
  }

  private node* takeLowestNode(node* nde, int dir) {
    while(!nextIsNull(nde,dir)) {
      nde = nextNode(nde, dir);
    } if(isLeaf(nde)) {
      modifyTreeSize(nde, -1);
      return takeLeaf(nde);
    } return takeFromList(nde);
  }

  private void swapValues(node* current,node* leaf) {
    T temp = leaf.payload;
    long tempVal = leaf.val;
    leaf.val = current.val;
    leaf.payload = current.payload;
    leaf.treeSize = current.treeSize;
    current.val = tempVal;
    current.payload = temp;
  }

  private void attachChild(node* current,node* nde, int idx) {
    current.nodes[idx] = nde;
    if(current.nodes[idx] !is null) {
      current.nodes[idx].nodes[up] = current;
    }
  }

  private node* nextNode(node* nde, int idx) {
    return nde.nodes[idx];
  }

  private bool nextIsNull(node* current, long val) {
    return current.nodes[val] is null;
  }

  private int direction(node* current,node* nde) {
    return cast(int) (current.val < nde.val);
  }

  private void modifyTreeSize(node* nde, int addOrSub) {
    while(nde !is root) {
      nde.treeSize += addOrSub;
      nde = parent(nde);
    } root.treeSize += addOrSub;
  }

  private node* parent(node* nde) {
    return nde.nodes[up];
  }

  private void returnToStack(node* nde) {
    if(nde is null) { return; }
    clearNode(nde);
    nde.payload = cast(T) null;
    if(stack is null) {
      stack = nde;
    } else {
      nde.nodes[up] = stack;
      stack = nde;
    }
  }

  private void clearNode(node* nde) {
    nde.nodes[left] = null;
    nde.nodes[right] = null;
    nde.nodes[up] = null;
    nde.treeSize = 0;
  }

  private bool unbalanced(node* nde) {
    if(nde.treeSize < 3) { return false; }

    if(nextIsNull(nde,left) ||
      nextIsNull(nde,right)) {
      return true;
    }
    long leftSize = nde.nodes[left].treeSize;
    long rightSize = nde.nodes[right].treeSize;
    return leftSize > 2*rightSize || rightSize > 2*leftSize;
  }

  private void balanceTree(node* nde) {
    if(nde is root) {
      head = null;
      balance();
      return;
    }
    node* parent = parent(nde);
    int idx = direction(parent, nde);
    detachParentAndChild(parent, idx);
    head = null;
    listify(nde);
    attachChild(parent, rebuild(head,right), idx);
  }

  private void detachParentAndChild(node* nde, int direction) {
    if(nde.nodes[direction] !is null) {
      nde.nodes[direction].nodes[up] = null;
    } nde.nodes[direction] = null;
  }

  private void listify(node* nde) {
    if(nde is null) { return; }

    node* LHS = nde.nodes[left];
    node* RHS = nde.nodes[right];
    clearNode(nde);

    listify(LHS);

    if(head is null) {
      head = nde;
      head.treeSize = 1;
    } else {
      nde.nodes[left] = head;
      nde.treeSize = head.treeSize + 1;
      head.nodes[up] = nde;
      head = nde;
    }

    listify(RHS);
  }

  private node* rebuild(node* nde,int nodesIdx) {
    if(nde is null) { return null; }
    long half = nde.treeSize /2;
    int reverse = 1-nodesIdx;
    for(int i; i < half; i++) {
      nde = rotate(nde,nodesIdx);
    }
    node* temp = nde.nodes[reverse];
    detachParentAndChild(nde,reverse);

    attachChild(nde, rebuild(temp, nodesIdx), reverse);

    temp = nde.nodes[nodesIdx];
    detachParentAndChild(nde,nodesIdx);

    attachChild(nde, rebuild(temp, reverse), nodesIdx); 
    return nde;
  }

  private node* rotate(node* nde,int idx) {
    int addTo = 1;
    if(! nextIsNull(nde, idx)) {
      addTo += nde.nodes[idx].treeSize;
    }
    node* temp = nextNode(nde,1-idx);

    promoteChild(temp, idx);
    temp.treeSize += addTo;

    demoteParent(nde,1-idx);
    nde.treeSize = addTo;

    return temp;
  }

  private void promoteChild(node* temp,int idx) {
    temp.nodes[idx] = temp.nodes[up];
    temp.nodes[up] = null;
  }

  private void demoteParent(node* nde,int idx) {
    nde.nodes[up] = nde.nodes[idx];
    nde.nodes[idx] = null;
  }

  public void printOut() {
    traverse(root);
    writeln("\n");
  }

  private final void traverse(node * current) {
    if(current is null) { return; }
    traverse(current.nodes[left]); 
    contour(current.treeSize);
    
    if(current == root) { write("root "); }
    static if(is(current.payload == class)) {
      write("Class");
    } else {
      write(current.val);
    }
    write(", nodes: ");
    writeln(current.treeSize);
    traverse(current.nodes[right]);
  }

  private final void contour(long levels) {
    for(long i = 1; i < levels; i++) {
      write("-");
    }
  }

  // ---------Testing Code------------
  private int testSize() {
    return counter(root, 0);
  }

  private int counter(node* nde, int target) {
    if(nde is null) { return 0; }
    target += counter(nde.nodes[left], 0);
    target += counter(nde.nodes[right], 0);

    target++;
    if(target != nde.treeSize) {
      writeln("ERROR: treeCount inaccurate, 
      reported ", nde.treeSize, " but is ", target);
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