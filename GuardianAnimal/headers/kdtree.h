#ifndef KDTREE_H
#define KDTREE_H

#include "JobTicket.h"
#include <cmath>
#include <vector>
#include <limits>

// Node Structure for the Tree
struct KDNode {
    JobTicket data;
    KDNode* left = nullptr;
    KDNode* right = nullptr;

    KDNode(JobTicket d) : data(d) {}
    ~KDNode() { delete left; delete right; }
};

class KDTree {
private:
    KDNode* root = nullptr;


    double distance(const QGeoCoordinate& c1, const QGeoCoordinate& c2) const {
        return c1.distanceTo(c2); // Qt's highly optimized math
    }

    KDNode* insertRec(KDNode* node, JobTicket ticket, int depth) {
        if (node == nullptr) return new KDNode(ticket);

        int dim = depth % 2;

        double val = (dim == 0) ? ticket.location.latitude() : ticket.location.longitude();
        double nodeVal = (dim == 0) ? node->data.location.latitude() : node->data.location.longitude();

        if (val < nodeVal)
            node->left = insertRec(node->left, ticket, depth + 1);
        else
            node->right = insertRec(node->right, ticket, depth + 1);

        return node;
    }

    void rangeSearchRec(KDNode* node, const QGeoCoordinate& center, double radiusMeters, int depth, std::vector<QString>& results) {
        if (node == nullptr) return;

        double d = distance(node->data.location, center);
        if (d <= radiusMeters) {
            results.push_back(node->data.animalId);
        }

        int dim = depth % 2;
        double centerVal = (dim == 0) ? center.latitude() : center.longitude();
        double nodeVal = (dim == 0) ? node->data.location.latitude() : node->data.location.longitude();

        double radiusDeg = radiusMeters / 111000.0;

        if (centerVal - radiusDeg < nodeVal)
            rangeSearchRec(node->left, center, radiusMeters, depth + 1, results);
        if (centerVal + radiusDeg > nodeVal)
            rangeSearchRec(node->right, center, radiusMeters, depth + 1, results);
    }

public:
    KDTree() {}
    ~KDTree() { delete root; }

    void insert(JobTicket ticket) {
        root = insertRec(root, ticket, 0);
    }

    // Returns IDs of animals within 'radiusKm'
    std::vector<QString> rangeSearch(QGeoCoordinate center, double radiusKm) {
        std::vector<QString> results;
        rangeSearchRec(root, center, radiusKm * 1000.0, 0, results);
        return results;
    }

    std::vector<QString> findNearest(QGeoCoordinate center, int k) {
        // Collect all tickets (Flatten tree)
        std::vector<std::pair<double, QString>> allNodes;
        flatten(root, center, allNodes);

        std::sort(allNodes.begin(), allNodes.end());

        std::vector<QString> results;
        for (int i = 0; i < std::min((int)allNodes.size(), k); i++) {
            results.push_back(allNodes[i].second);
        }
        return results;
    }

private:
    void flatten(KDNode* node, const QGeoCoordinate& center, std::vector<std::pair<double, QString>>& list) {
        if (!node) return;
        double d = distance(node->data.location, center);
        list.push_back({d, node->data.animalId});
        flatten(node->left, center, list);
        flatten(node->right, center, list);
    }
};

#endif // KDTREE_H
