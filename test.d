import BST: BST;
import std.stdio: writeln;
import std.random;
import Stack: Stack;

void main() {
  writeln("Testing.");
  for(int i = 0; i < 10; i++) {
    testRun(8000000);
    writeln("Done ", i, " rounds.");
  }
  writeln("Done");

}

void testRun(long k) {
  auto Tree = new BST!long;
  long rand = 0;
  for(long i = 0; i < k; i++) {
    rand = uniform(1, k + (k/2));
    if(i%1000000 == 0) {
      writeln(i);
    }
    Tree.insert(rand);
  }

  Tree.balance();
}
