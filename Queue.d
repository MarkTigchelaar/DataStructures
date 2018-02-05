module Queue;
class Queue(T) {
  import commonTypes;
  private:
  	node!T* front;
  	node!T* rear;
  	long len;

  public:

  final void enqueue(node!T* temp) {
    if(front is null) {
      front = temp;
      rear = front;
    } else {
      rear.nodes[2] = temp;
      rear = temp;
    } len++;
  }

  final void enqueueItem(T item) {
  	enqueue(new node!T(item));
  }

  final T dequeueItem() {
    if(front is null) {
      return cast(T) null;
    }
    T value = front.payload;
    front = front.nodes[2];
    len--;
    return value;
  }

  final node!T* dequeue() {
  	if(front is null) {
  	  return null;
  	}
  	node!T* temp = front;
  	front = front.nodes[2];
  	temp.nodes[2] = null;
  	len--;
  	return temp;
  }

  final T peek() {
  	if(front is null) {
  	  return cast(T) null;
  	} return front.payload;
  }

  final void clear() {
    front = null;
    rear = null;
    len = 0;
  }

  final int length() {
  	return len;
  }

  final bool isEmpty() {
  	return len == 0;
  }
}
