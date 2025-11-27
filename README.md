# Patitas Suaves
Proyecto de programación 3, Plataforma de asistencia para animales en riesgo


# Patitas Suaves, Documentación.
## necesidades No Satisfechas…..
### Problema Central: 
La gestión de emergencias y reportes de bienestar animal en entornos locales es casi inexistente . La falta de un sistema lleva a retrasos críticos, comprometiendo el bienestar animal.

### Solución: 
Nuestro proyecto aplica Estructuras de Datos y Algoritmos (DSA) de alto rendimiento (Max-Heap para prioridad, Árboles K-D para búsqueda espacial y Tablas Hash para recuperación instantánea) implementados en C++ (Qt) para asegurar:

 Priorización Instantánea: El Max-Heap garantiza que el reporte más crítico (mayor priority) sea el elemento superior para el despacho inmediato.
 
Optimización de Búsqueda: El Árbol K-D permite a los rescatistas o a los ciudadanos encontrar reportes cercanos eficientemente, optimizando la asignación de recursos.

Unificación Rápida: La interfaz QML proporciona un flujo de trabajo intuitivo y unificado para la gestión de rescates y mascotas perdidas/encontradas.

Todo esto nos permite la integración de un sistema practico para la atención y gestión de emergencias en tiempo real y crítico.

## Nuestros objetivos:
### Respuesta en Tiempo Real
Reducir el tiempo promedio entre la inserción de un reporte crítico en el Max-Heap y su presentación al rescatista a menos de 500 milisegundos.

### Eficiencia Algorítmica
Asegurar que las operaciones clave de inserción y recuperación (Max-Heap y Hash Table) mantengan una complejidad de tiempo de O(log n) o mejor.

### Usabilidad y Adopción
Lograr que un rescatista complete un ciclo de rescate (Aceptar Caso -> Navegar -> Finalizar) en menos de 5 clics en la interfaz QML.

## Personas Clave
### Rescatista/Operador de Campo (Focus Primario): Utiliza la aplicación (RescueListView.qml, NavigationView.qml) para recibir, priorizar y navegar a las emergencias. Necesita información de ruta rápida y alertas de proximidad).

### Ciudadano Reportero: Usuario que reporta una emergencia (ReportView.qml) o un avistamiento de mascota (LostFoundView.qml). Necesita un proceso de reporte sencillo y rápido.
 
## Historias de Trabajo ("Job Stories")
### Contexto: 
Cuando se reporta un caso de Prioridad ALTA (Perro Atropellado).

### Necesidad del Usuario:
Quiero que ese caso sea extraído inmediatamente del Max-Heap y se me presente en la cima de mi lista de tarea.

### Resultado Deseado
 Para poder dirigirme a la emergencia más grave sin segundos de retraso.


# Arquitectura y Estructuras de Datos (DSA)

## Arquitectura de C++ y QML
El proyecto se basa en el patrón Model-View-ViewModel (MVVM), donde el MapManager en C++ actúa como el Modelo (Datos y Lógica) y el QML como la Vista.

### Clase Central:
MapManager (Hereda de QObject). Estructura de Datos: RescueReport (Q_GADGET para eficiencia, ver rescuereport.h).

### Cola de Prioridad (Max-Heap)
La Cola de Prioridad, implementada en C++ como una std::priority_queue con un comparador (ReportComparator), es la responsable de la Priorización de Rescates. Su función es garantizar que la emergencia más grave sea siempre la primera en ser atendida. Dado que la inserción y la extracción del elemento de mayor prioridad se realizan en tiempo O(log n), es un mecanismo eficiente crucial para un sistema de respuesta en tiempo real. La ReportComparator evalúa el campo priority del objeto RescueReport para definir qué caso es más urgente, asegurando que la lista de reportes (sortedReports) expuesta a QML esté siempre ordenada por relevancia de vida o muerte.

### Tabla Hash
La Tabla Hash, utilizada en C++ como QHash<int, RescueReport> m_allReports, sirve como el Almacén Maestro de Reportes con capacidad de Recuperación por ID. Su principal ventaja es que permite la búsqueda, inserción y eliminación de un reporte específico en un tiempo promedio de O(1) (tiempo constante). Es esencial para funcionalidades como la consulta instantánea de detalles de un animal (a partir de un ID único, como un microchip) o para obtener las coordenadas de un reporte de forma inmediata antes de iniciar la navegación. La velocidad de esta estructura elimina la necesidad de escanear grandes listas de datos, optimizando el rendimiento.

### Árbol K-D Dinámico
El Árbol K-D Dinámico (struct KDNode y sus métodos insert(), findKNearestNeighbors()) se emplea para la Búsqueda Espacial dentro de la aplicación. Esta estructura de datos particiona el espacio geográfico (coordenadas de latitud y longitud) en una jerarquía de nodos. Su complejidad de búsqueda es, en promedio, O(log n), lo que es extremadamente eficiente para localizar reportes dentro de un área específica. Se utiliza específicamente en la función updateNearestReports() para encontrar y exponer a QML los K reportes más cercanos al rescatista, permitiendo una asignación de recursos basada en la proximidad geográfica.
 
### Exposición de Datos (C++ a QML)
La clase principal en C++, MapManager, se encarga de exponer los datos priorizados a la interfaz de usuario. La lista de rescates ordenados se presenta a QML a través de una propiedad llamada Q_PROPERTY(QVariantList sortedReports READ sortedReports NOTIFY reportsChanged). Dado que la std::priority_queue (Max-Heap) no puede ser leída directamente por QML, se utiliza un mecanismo intermedio: el método privado updateSortedList() se encarga de vaciar temporalmente el Max-Heap a una lista auxiliar (QList<RescueReport>). Esta lista es la que QML puede iterar y mostrar en la vista RescueListView.qml. Cada vez que se añade o se despacha un reporte, se actualiza esta lista auxiliar y se emite la señal reportsChanged para notificar a la interfaz de que los datos han cambiado y deben ser refrescados.

### Estructura de Datos Auxiliar: RescueReport
La unidad fundamental de datos para representar una emergencia es la clase RescueReport. Esta se define como un Q_GADGET, una estructura de datos pura que no hereda de QObject. Esta elección la hace particularmente ligera y eficiente, ya que no necesita lógica de negocio ni manejo de red, y puede ser transferida por valor (QVariant::fromValue) al motor QML sin el overhead de un objeto completo. Sus campos de datos clave incluyen el id del reporte, la coordinate (una QGeoCoordinate para la ubicación) y la priority (un entero), siendo este último el valor fundamental que usa el Max-Heap para el ordenamiento y la priorización.

### Capa de Presentación (QML)
La interfaz de usuario está diseñada con un enfoque modular.

### Flujo de Aplicación (Main.qml)
El archivo Main.qml es el punto de control central de la aplicación. Utiliza una propiedad entera, appState, que controla el flujo de inicio, definiendo el estado actual: Splash (0), Permisos (1), Login (2), o la Aplicación Principal (3). Un componente Loader carga dinámicamente la vista correspondiente (por ejemplo, SplashScreen, LoginScreen) basándose en el valor de este estado. Este archivo también contiene el componente LocationPermission de Qt, esencial para gestionar el consentimiento del usuario para las funcionalidades basadas en ubicación.

### Contenedor Principal (ApplicationScreen.qml)
Este archivo actúa como el shell de la aplicación, definiendo el diseño global, incluyendo el encabezado, el pie de página (ViewSwitch) y el área de contenido gestionada por un StackLayout. Las propiedades booleanas globales, como navigationActive, reportActive, y detailActive, son clave para la gestión de la interfaz de usuario: estas controlan si se deben ocultar o deshabilitar elementos globales (como el pie de página) cuando una vista modal o de navegación específica está activa, asegurando una experiencia de usuario enfocada.

### Vistas Específicas QML

RescueListView.qml: Esta vista muestra la lista de emergencias, que está enlazada al MapManager.sortedReports, asegurando que los casos se presenten al rescatista en orden de prioridad. Al seleccionar "Aceptar Caso", se dispara la lógica en C++ para calcular la ruta.

LostFoundView.qml: Maneja la funcionalidad de mascotas perdidas y encontradas. Contiene sus propios modelos locales (ListModel) para mostrar reportes y tiene botones de acción para reportar un avistamiento.

ReportView.qml: Es el formulario que usan los ciudadanos para reportar una emergencia, e incluye una simulación del proceso de obtención de la ubicación GPS.

NavigationView.qml: Se activa cuando un caso es aceptado. Esta vista simula la navegación en tiempo real, mostrando la distancia al objetivo decreciendo. Su lógica incluye el Geofence Warning, que es una alerta de proximidad que se activa al acercarse al punto de destino.

### Conectores (Red)
El MapManager no solo gestiona los datos algorítmicos, sino también la conectividad de red necesaria para las funciones de mapeo. El método clave de red es la función getRoute(startLat, startLon, endLat, endLon), la cual es un método invocable (Q_INVOKABLE) desde QML. Esta función está diseñada para interactuar con una API de mapas externa (simulada o real, como Google Maps) para obtener la polilínea de la ruta. Un método privado auxiliar, decodePolyline(), implementa el algoritmo estándar necesario para convertir la cadena codificada de la API en una lista utilizable de coordenadas (QList<QGeoCoordinate>). Una vez decodificada, la ruta final se envía de vuelta a QML a través de la señal routeReady(QVariantList) para que la interfaz pueda dibujarla en el mapa.

## Historia, Restricciones y Decisiones, Alternativas Descartadas:
### Alternativa para Priorización:
En lugar del Max-Heap, se consideró usar una QList y ordenarla con std::sort cada vez que se agregaba un reporte.

### Razón del Descarte: 
Ordenar con std::sort es O(n log n), mientras que la inserción y la extracción del Max-Heap es solo O(log n). Descartamos la alternativa de lista simple porque penalizaría el rendimiento en sistemas con alto volumen de reportes, violando el objetivo de Respuesta en Tiempo Real.
Restricciones Técnicas

### Ubicación Real y Rutas: 
El proyecto simula la obtención de rutas (función getRoute en MapManager.cpp) y la actualización de la distancia GPS (Timer en NavigationView.qml). La dependencia de APIs de mapas externas (como Google Maps) se maneja a través de una función de decodificación de polilíneas estáticas (decodePolyline).
Persistencia: Los datos son efímeros. Todos los reportes residen únicamente en la memoria RAM del MapManager (m_allReports y m_priorityQueue). No hay integración con bases de datos (Firestore, SQL), lo que restringe el uso en producción a un entorno de demostración.

### Integración C++/QML: 
La std::priority_queue no puede ser accedida directamente por QML. Esto obligó a crear una estructura auxiliar (QList<RescueReport> m_sortedReports) y un método (updateSortedList()) que vacía temporalmente el Heap para exponer los datos a la UI vía Q_PROPERTY.


# Exploraciones y Decisiones Clave
Se exploraron y tomaron decisiones clave para optimizar el desarrollo. Respecto al Objeto de Reporte (RescueReport), se consideró usar QObject, lo cual facilitaría la exposición de propiedades y señales individuales a QML, pero generaba problemas en le desarrollo. La decisión final fue usar Q_GADGET, ya que permite pasar la estructura por valor a QML (QVariant::fromValue) sin el costo de QObject.
