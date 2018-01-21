class Stack(T) {
  import core.stdc.stdlib: exit;
  import std.stdio: writeln;
  private:

  struct stk_node {
    T item;
    stk_node * next;
  }
  stk_node * root;
  int len = 0;

  public:

  final void push(T item) {
    if(len == 0) {
      root = new stk_node(item,null);
    } else {
      stk_node * newNode = new stk_node(item, null);
      newNode.next = *&root;
      root = newNode;
    } len++;
  }

  final T pop() {
    if(len == 0) {
      writeln("ERROR: Empty Stack.");
      exit(0);
    }
    T value;
    value = root.item;
    root = root.next;
    len--;
    return value;
  }

  final void clear() {
    root = null;
    len = 0;
  }

  final T peek() { return root.item; }

  final int length() { return len; }
}