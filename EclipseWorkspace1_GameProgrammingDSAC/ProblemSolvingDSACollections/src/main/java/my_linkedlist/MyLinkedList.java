package my_linkedlist;

public class MyLinkedList {
	public static void main(String[] args) {
		LL ll1 = new LL(new LL.Node(10));
		
		ll1.addNodeAtEnd(20);
		
		ll1.printLL();
	}

	
}


class LL{
	Node head;
	
	LL(Node head){
		this.head = head;
	}
	
	static class Node{
		int data;
		Node next;
		Node(int data){
			this.data = data;
		}
	}
	
	void printLL() {
		Node dummyHead = this.head;
		while(dummyHead!=null) {
			System.out.print(dummyHead.data + " ");
			dummyHead = dummyHead.next;
		}
	}
	
	Node addNodeAtEnd(int data){
		Node tail = this.getTailNode(this.head);
		System.out.println(tail.data);
		tail.next = new LL.Node(data);
		return tail.next;
	}
	
	Node getTailNode(Node head) {
		Node dummyHead = head;
		Node prevToDummyHead = null;
		while(dummyHead != null) {
			prevToDummyHead = dummyHead;
			dummyHead = dummyHead.next;
		}
		return prevToDummyHead;
	}
	
}