class Queue(T) {
  import core.stdc.stdlib: exit;
  import std.stdio: writeln;
  private:

  struct qnode {
    T item;
    qnode * next;
  }
  qnode * front;
  qnode * rear;

  int len;

  public:

  final void enqueue(T item) {
    if(len == 0) {
      front = new qnode(item, null);
      rear = front;
    } else {
      qnode * newqnode = new qnode(item, null);
      rear.next = *&newqnode;
      rear = newqnode;
    } len++;
  }

  final T dequeue() {
    if(len == 0) {
      writeln("ERROR: Empty Queue.");
      exit(0);
    }
    T value;
    value = front.item;
    front = front.next;
    len--;
    return value;
  }

  final T peek() { return front.item; }

  final void clear() {
    front = null;
    rear = null;
    len = 0;
  }
  final int length() { return len; }
}
