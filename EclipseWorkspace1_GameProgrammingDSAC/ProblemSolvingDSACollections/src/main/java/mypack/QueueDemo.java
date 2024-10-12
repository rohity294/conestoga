package mypack;

import java.util.PriorityQueue;
import java.util.Queue;

public class QueueDemo {
	public static void main(String[] args) {
		Queue<Integer> qu = new PriorityQueue<Integer>();
		qu.add(10);qu.offer(20);qu.add(30);qu.add(40);qu.add(50);
		
		for(int item :qu) {
			System.out.print(item + " ");
		}
		System.out.println();
		System.out.println(qu.size());
		
		System.out.println(qu.remove());
		System.out.println(qu.size());
		
		System.out.println(qu.peek());
		System.out.println(qu.size());
	}
}
