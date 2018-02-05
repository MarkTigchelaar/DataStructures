module Stack;
class Stack(T) {
  import commonTypes;

  private:
    node!T* root;
  public:

  final void pushItem(T item) {
    push(new node!T(item));
  }

  final void push(node!T* temp) {
    if(root is null) {
      root = temp;
      root.size = 1;
    } else {
      temp.nodes[2] = root;
      temp.size = root.size + 1;
      root = temp;
    }
  }

  final T popItem() {
    if(root is null) {
      return cast(T) null;
    }
    node!T* temp;
    T value = root.payload;
    temp = root;
    root = root.nodes[2];
    return value;
  }

  final node!T* pop() {
    if(root is null) {
      return null;
    }
    node!T* temp;
    temp = root;
    root = root.nodes[2];
    return temp;
  }

  final void clear() {
    root = null;
  }

  final T peek() {
    return root.payload;
  }

  final long length() {
    if(root is null) {
      return 0;
    } return root.size;
  }

  final bool isEmpty() {
    return root is null;
  }
}