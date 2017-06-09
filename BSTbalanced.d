import std.stdio: writeln;
import core.stdc.stdlib: exit;
import BSTbase: BSTbase;

class BSTbalance(T) : BSTbase {

  private int leftTreeSize;
  private int rightTreeSize;

  public final void rebalance() {
    if(root is null) { return; }

    balancer(root);

  }
  public final void rebalance(tree_node * current) {
    if(current is null) { return; }

    balancer(current);
  }
  private void balancer(tree_node * current) {
    return;
  }
}
