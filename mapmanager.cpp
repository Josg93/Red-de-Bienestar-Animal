#include <QDebug>
#include <QUrl>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "mapmanager.h"
#include "rescuereport.h"
#include <QVariant>


MapManager::MapManager(QObject *parent) : QObject(parent)
{
    m_networkManager = new QNetworkAccessManager(this);
}


//Destruir arbol KD
MapManager::~MapManager()
{
    // Limpiar la memoria del Árbol K-D para evitar fugas
    clearKdTree(m_kdTreeRoot);
}
void MapManager::clearKdTree(KDNode* node) {
    if (!node) return;
    clearKdTree(node->left);
    clearKdTree(node->right);
    delete node;
}


//Ordenar reportes a mostrar QML ---------------------
void MapManager::updateSortedList()
{
    m_sortedReports.clear();
    std::priority_queue<RescueReport, std::vector<RescueReport>, ReportComparator> tempQueue = m_priorityQueue;

    while (!tempQueue.empty()) {
        m_sortedReports.append(tempQueue.top());
        tempQueue.pop();
    }
}

//getter para QML
QVariantList MapManager::sortedReports() const
{
    QVariantList list;

    for (const RescueReport& report : m_sortedReports) {
        list.append(QVariant::fromValue(report));
    }
    return list;
}
//---------------------------------------------------





MapManager::KDNode* MapManager::insert(KDNode* node, int id, const QGeoCoordinate& coord, int depth)
{
    if (node == nullptr) {
        return new KDNode(id, coord);
    }

    // Nota: Aquí no se maneja la eliminación para simplificar.
    // Si el ID ya existe, simplemente lo ignoramos o podrías manejarlo como una actualización.
    // Para K-D Tree de puntos fijos, la posición debe ser única.

    const int k = 2; // Latitud y Longitud
    int axis = depth % k;

    // Comparar según el eje actual
    if (axis == 0) { // Eje: Latitud
        if (coord.latitude() < node->coordinate.latitude()) {
            node->left = insert(node->left, id, coord, depth + 1);
        } else {
            node->right = insert(node->right, id, coord, depth + 1);
        }
    } else { // Eje: Longitud
        if (coord.longitude() < node->coordinate.longitude()) {
            node->left = insert(node->left, id, coord, depth + 1);
        } else {
            node->right = insert(node->right, id, coord, depth + 1);
        }
    }

    return node;
}

void MapManager::insertNode(int id, const QGeoCoordinate& coord)
{
    m_kdTreeRoot = insert(m_kdTreeRoot, id, coord, 0);
}



//--- k=5 vecinos cercanos
void MapManager::findKNearestNeighbors(const QGeoCoordinate& target, KDNode* node, int depth,
    std::priority_queue<std::pair<double, RescueReport>,
                        std::vector<std::pair<double, RescueReport>>,
                        DistanceComparator>& topK)
    {

    if (!node){return;}

    const int k = 2;
    const int maxK = 5; // Siempre buscamos los 5 más cercanos

    // 1. Calcular distancia y actualizar Max-Heap
    // Usamos la distancia esférica (en metros)
    double distance = target.distanceTo(node->coordinate);


    // Obtener el objeto RescueReport completo desde la QHash usando el ID
    // Ignorar el nodo si el reporte fue eliminado lógicamente de la Hash
    if (!m_allReports.contains(node->reportId)) {return;}
    const RescueReport& report = m_allReports.value(node->reportId);

    //condicion de parada del ciclo recursivo
    if (topK.size() < maxK) {
        topK.push({distance, report});
    } else if (distance < topK.top().first) {
        topK.pop();
        topK.push({distance, report});
    }



    // 2. Determinar qué lado buscar primero
    int axis = depth % k;
    double targetCoordValue = (axis == 0) ? target.latitude() : target.longitude();
    double nodeCoordValue = (axis == 0) ? node->coordinate.latitude() : node->coordinate.longitude();

    KDNode* nearChild = (targetCoordValue < nodeCoordValue) ? node->left : node->right;
    KDNode* farChild = (targetCoordValue < nodeCoordValue) ? node->right : node->left;

    // 3. Buscar en el lado más cercano
    findKNearestNeighbors(target, nearChild, depth + 1, topK);

    // 4. Poda (Pruning): ¿Necesitamos buscar en el otro lado?
    // Convertimos la diferencia de coordenada al eje a metros de forma aproximada
    // (111000m/grado) para compararlo con la distancia del punto más lejano en el Max-Heap.
    double diff = std::abs(targetCoordValue - nodeCoordValue) * 111000.0;

    // Si la distancia del hiperplano de división al objetivo es menor que la distancia del
    // reporte más lejano encontrado (topK.top().first), hay que revisar el otro lado.
    if (topK.size() < maxK || diff < topK.top().first)
    {
        findKNearestNeighbors(target, farChild, depth + 1, topK);
    }
}




// Función que ejecuta el flujo K-D Tree -> Priority Queue -> QML
void MapManager::updateNearestReports(double rescuerLat, double rescuerLon, int k)
{
    if (!m_kdTreeRoot || m_allReports.isEmpty()) {
        qDebug() << "ADVERTENCIA: Árbol K-D vacío. No se han añadido reportes.";
        // Limpiar la lista visible
        m_priorityQueue = std::priority_queue<RescueReport, std::vector<RescueReport>, ReportComparator>();
        updateSortedList();
        emit reportsChanged();
        return;
    }

    QGeoCoordinate rescuerCoord(rescuerLat, rescuerLon);

    // Max-heap temporal para el K-NN: {distancia_metros, RescueReport}
    std::priority_queue<
        std::pair<double, RescueReport>,
        std::vector<std::pair<double, RescueReport>>,
        DistanceComparator
        > topKReports;

    // 1. Buscar los K vecinos más cercanos con el Árbol K-D (K=5 por defecto)
    findKNearestNeighbors(rescuerCoord, m_kdTreeRoot, 0, topKReports);

    qDebug() << "Búsqueda K-D Tree completada. Encontrados" << topKReports.size() << "reportes más cercanos.";

    // 2. Limpiar la cola de prioridad de la vista (m_priorityQueue)
    // Se usa la asignación para resetear eficientemente
    m_priorityQueue = std::priority_queue<RescueReport, std::vector<RescueReport>, ReportComparator>();

    // 3. Insertar los K reportes encontrados en la cola de prioridad de la vista
    // Esto ordena los 5 reportes por PRIORIDAD.
    while (!topKReports.empty()) {
        m_priorityQueue.push(topKReports.top().second);
        topKReports.pop();
    }

    // 4. Actualizar la QList para QML y notificar a la vista
    updateSortedList();
    emit reportsChanged();

    qDebug() << "Cola de prioridad de la vista actualizada (ordenada por Prioridad).";
}


// Modificado: Ahora solo añade a la QHash y al Árbol K-D dinámicamente
void MapManager::addReport(int id, double lat, double lon, int priority)
{
    QGeoCoordinate coord(lat, lon);
    RescueReport newReport(id, coord, priority);

    // 1. Añadir/Actualizar en la Lista Maestra (QHash)
    m_allReports.insert(id, newReport);

    // 2. Insertar en el Árbol K-D de forma dinámica
    insertNode(id, coord);

    // Opcional: Podrías llamar a updateNearestReports aquí, pero es mejor que el QML lo
    // llame periódicamente o por acción del usuario/movimiento del rescatista.
}



void MapManager::calculateRouteToReport(double rescuerLat, double rescuerLon, int reportId)
{
    // Usamos QHash para encontrar el reporte por ID en O(1)
    if (!m_allReports.contains(reportId)) {
        qWarning() << "Error: Reporte ID" << reportId << "no encontrado en la lista maestra (QHash).";
        return;
    }

    const RescueReport& report = m_allReports.value(reportId);
    QGeoCoordinate targetCoord = report.coordinate();

    qDebug() << "Calculando ruta a Reporte ID:" << reportId << "en" << targetCoord.latitude() << targetCoord.longitude();
    getRoute(rescuerLat, rescuerLon, targetCoord.latitude(), targetCoord.longitude());
}



//MANEJO GOOGLE API ---------------------------------------------------------------------------------
void MapManager::getRoute(double startLat, double startLon, double endLat, double endLon)
{
    QString urlString = QString("https://maps.googleapis.com/maps/api/directions/json?origin=%1,%2&destination=%3,%4&key=%5")
    .arg(startLat).arg(startLon).arg(endLat).arg(endLon).arg(m_apiKey);

    QNetworkRequest request((QUrl(urlString)));
    QNetworkReply *reply = m_networkManager->get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            // 1. Parse the JSON
            QByteArray responseData = reply->readAll();
            QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
            QJsonObject jsonObj = jsonDoc.object();

            // 2. Check status
            if (jsonObj["status"].toString() == "OK") {
                // 3. Extract the "overview_polyline" string
                QJsonArray routes = jsonObj["routes"].toArray();
                QJsonObject route = routes[0].toObject();
                QJsonObject polylineObj = route["overview_polyline"].toObject();
                QString encodedPoints = polylineObj["points"].toString();

                // 4. Decode it into real coordinates
                QList<QGeoCoordinate> path = decodePolyline(encodedPoints);

                // 5. Convert to QVariantList for QML
                QVariantList qmlPath;
                for (const QGeoCoordinate &coord : path) {
                    qmlPath.append(QVariant::fromValue(coord));
                }

                // 6. Send to QML!
                emit routeReady(qmlPath);
                qDebug() << "Route found with" << path.size() << "points. Sent to QML.";

            } else {
                qDebug() << "Google Error:" << jsonObj["status"].toString();
            }
        } else {
            qDebug() << "Network Error:" << reply->errorString();
        }
        reply->deleteLater();
    });
}



// This is the standard algorithm to decode Google's Polyline format
QList<QGeoCoordinate> MapManager::decodePolyline(const QString &encoded)
{
    QList<QGeoCoordinate> points;
    int index = 0, len = encoded.length();
    int lat = 0, lng = 0;

    while (index < len) {
        int b, shift = 0, result = 0;
        do {
            b = encoded[index++].toLatin1() - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
            b = encoded[index++].toLatin1() - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.append(QGeoCoordinate(lat * 1e-5, lng * 1e-5));
    }
    return points;
}
