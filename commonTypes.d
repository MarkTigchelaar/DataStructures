module commonTypes;

struct node(T) {
  T payload;
  long val = 0;
  node*[3] nodes;
  long size = 0;
}

interface NetworkNode {
	long compareFunction();
	string getKey();
	void subscribe(NetworkNode[] newObservers);
	void unsubscribe(NetworkNode[] oldObservers);
}

interface DataStructure {
	void push();
	bool isEmpty();
	long length();
	
}