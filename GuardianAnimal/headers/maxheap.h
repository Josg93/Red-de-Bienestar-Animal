#ifndef MAXHEAP_H
#define MAXHEAP_H

#include "JobTicket.h"
#include <vector>
#include <algorithm>

class MaxHeap {
private:
    std::vector<JobTicket> heap;

    int parent(int i) { return (i - 1) / 2; }
    int left(int i) { return (2 * i) + 1; }
    int right(int i) { return (2 * i) + 2; }

    void heapifyUp(int i) {
        while (i > 0 && heap[parent(i)] < heap[i]) {
            std::swap(heap[i], heap[parent(i)]);
            i = parent(i);
        }
    }

    void heapifyDown(int i) {
        int maxIndex = i;
        int l = left(i);
        int r = right(i);

        if (l < heap.size() && heap[maxIndex] < heap[l])
            maxIndex = l;

        if (r < heap.size() && heap[maxIndex] < heap[r])
            maxIndex = r;

        if (i != maxIndex) {
            std::swap(heap[i], heap[maxIndex]);
            heapifyDown(maxIndex);
        }
    }

public:
    void insert(JobTicket ticket) {
        heap.push_back(ticket);
        heapifyUp(heap.size() - 1);
    }

    JobTicket extractMax() {
        if (heap.empty()) return JobTicket(); // Handle empty case appropriately in prod

        JobTicket maxItem = heap[0];
        heap[0] = heap.back();
        heap.pop_back();
        heapifyDown(0);
        return maxItem;
    }

    JobTicket peek() const {
        if (heap.empty()) return JobTicket();
        return heap[0];
    }

    bool isEmpty() const { return heap.empty(); }
    int size() const { return heap.size(); }

    std::vector<JobTicket> getSortedList() const {
        std::vector<JobTicket> copy = heap;
        std::sort(copy.begin(), copy.end(), [](const JobTicket& a, const JobTicket& b) {
            return !(a < b);
        });
        return copy;
    }
};

#endif // MAXHEAP_H
