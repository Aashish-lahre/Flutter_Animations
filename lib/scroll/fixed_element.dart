import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FixedElement extends StatefulWidget {
  const FixedElement({super.key});

  @override
  State<FixedElement> createState() => _FixedElementState();
}

class _FixedElementState extends State<FixedElement> {
  ScrollController controller = ScrollController(initialScrollOffset: 0);
  List<int> indexes = [14, 3]..sort(); // Initial Fixed Items/Elements
  double listTileHeight = 100; // Height of each Item/Element
  late List<GlobalKey?> keys; // List of GlobalKeys for only Fixed Items/Elements
  List<Positioned> positioned = []; // List to Positioned Widgets, These widgets are the actual widgets that shows when I need to show the fixed Item/Element.
  int itemCount = 40; // Total item count
  late List<int> items;

  late final ValueNotifier<List<double>> selectedIndex; // New selected Indexes, later overrides the "indexes" when any index changes in select index appbar.

  // add positioned widget in List<Positioned> positioned
  // get called when Upcoming fixed item/element comes at fixedHeightFromTop
  Positioned addPositioned(int index, double position) {
    return Positioned(
      top: position,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        height: listTileHeight,
        child: Center(
          child: ListTile(
            title: Text('Item no - $index'),
          ),
        ),
      ),
    );
  }

  // Method to calculate size, position, and  fixed height from top
  List<List<double>> keyToRenderBoxSizeAndPositionAndFixedHeightFromTop(
      List<GlobalKey?> keys, List<int> indexes) {
    List<List<double>> sizeAndPositionAndFixedHeightFromTop = [];

    for (int i = 0; i < keys.length; i++) {
      Offset position = Offset.zero;
      if (keys[i]!.currentContext != null) {
        // Calculate the position if the context is available
        position = (keys[i]!.currentContext!.findRenderObject() as RenderBox)
            .localToGlobal(Offset.zero);
      } else {
        // Handle case where the element is not visible
        // If element is beneath viewport and do not exist because of lazy loading -->  Offset.Infinity
        // vice verse when element is above viewport and got removed.
        position = (indexes[i] * listTileHeight) > controller.position.pixels
            ? (Offset.infinite)
            : -Offset.infinite;
      }
      double fixedHeightFromTop = (sizeAndPositionAndFixedHeightFromTop.length * 100) + 100;
      sizeAndPositionAndFixedHeightFromTop.add([listTileHeight, position.dy, fixedHeightFromTop]);
    }
    return sizeAndPositionAndFixedHeightFromTop;
  }

  @override
  void initState() {
    // List<double> selected Index of appbar taking its initial values from List<int> indexes and converting toInt to toDouble
    selectedIndex = ValueNotifier(indexes.map((item) => item.toDouble()).toList());
    keys = List.generate(indexes.length, (index) => GlobalKey()); // Generating GlobalKeys for the 1st time.
    items = List.generate(itemCount, (index) => index + 1); // Generate a list of items

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.position.addListener(() {

        // fetches size, current position and fixedHeight from top of all fixed items, at every pixel change
        List<List<double>> sizeAndPositionAndFixedHeightFromTops =
        keyToRenderBoxSizeAndPositionAndFixedHeightFromTop(keys, indexes);


        // When User scrolling for bottom items
        if (controller.position.userScrollDirection ==
            ScrollDirection.reverse) {
          // for loop for every fixed item
          for (int i = 0; i < sizeAndPositionAndFixedHeightFromTops.length; i++) {

            // checking if this fixed item has reached its top(its fixed height position from top)
            if (sizeAndPositionAndFixedHeightFromTops[i][1] <=
                sizeAndPositionAndFixedHeightFromTops[i][2]) {

              // checking if actual fixed item positioned widget exists in positioned list.
              // check is necessary to avoid adding additional positioned widget for a particular fixed item even though a positioned widget exists for that particular fixed item.
              // if we do not check, after every pixel change that condition will return true and an extra positioned widget will be added.
              if (positioned.length < i + 1) {
                setState(() {
                  positioned.add(addPositioned(
                      indexes[i], sizeAndPositionAndFixedHeightFromTops[i][2]));
                });
              }
            }
          }
        }
        // when user scroll to see above items
        else {

          // if there is any item fixed at the top
          if (positioned.isNotEmpty) {

            // looping through last positioned item to first positioned item.
            for (int i = positioned.length - 1; i >= 0; i--) {

              // if the fixed item's position has come down to not fix this item.
              if (sizeAndPositionAndFixedHeightFromTops[i][1] >=
                  sizeAndPositionAndFixedHeightFromTops[i][2]) {

                setState(() {
                  // remove the fixed positioned item from the list of fixed positioned item widgets
                  positioned.removeLast();
                });
              }
            }
          }
        }

        // the the scroll view(Listview) is at pixel 0
        if (controller.position.pixels == 0) {
          // if there is no newly selected or unselected item from select dialog
          if (indexes == selectedIndex.value) {
            // do nothing
          } else {
            // remove all the previous global keys
            for (var key in keys) {
              key = null; // Reset keys
            }

            // remove all the fixed positioned widgets from the top
            positioned.clear();

            setState(() {

              // reassigning indexes from newly selected items
              // selectedIndex list contains every thing.
              indexes = selectedIndex.value
                  .map((double value) => value.toInt())
                  .toList();

              // sorting is important causes without it, it will messed up the fixed height from top of every fixed item.
              indexes.sort(); // Sort selected indexes

              // generating new global keys for existing and new fixed items.
              keys = List.generate(indexes.length, (index) => GlobalKey());
            });
          }
        }
      });
    });

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // stack widget to show fixed item on top of listview and to make whole appbar clickable.
      body: Stack(fit: StackFit.expand, children: [

        // ListView
        Positioned(
          top: 100,
          bottom: 0,
          left: 0,
          right: 0,
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            reverse: false,
            controller: controller,
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              return SizedBox(
                key: indexes.contains(index)
                    ? keys[indexes.indexOf(index)]
                    : null,
                height: listTileHeight,
                child: Center(
                  child: ListTile(
                    title: Text('Item no - $index'),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                height: 3,
              );
            },
          ),
        ),

        // Fixed Positioned widgets on top of ListView
        ...positioned,

        // Full clickable Appbar-like widget with a selection option
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Center(

                      // without material widget, code will break, ListTile widget needs material widget(Idk why)
                      child: Material(
                        // Big white container in showDialog box
                        child: Container(
                          width: MediaQuery.of(context).size.width - 50,
                          height: MediaQuery.of(context).size.height - 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [

                              // Select Heading
                              const SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: Center(
                                  child: Text(
                                    'Select',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),


                              // List of selectable items
                              Expanded(
                                  child: ValueListenableBuilder(
                                    valueListenable: selectedIndex,
                                    builder: (context, selectedList, child) {

                                      return ListView.separated(
                                        itemCount: itemCount,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: ListTile(

                                              // check box to select/unselect item
                                              leading: Checkbox(
                                                  value: selectedList
                                                      .contains(index)
                                                      ? true
                                                      : false,
                                                  onChanged: (newSelectedValue) {

                                                    if (newSelectedValue != null) {
                                                      if (newSelectedValue) {

                                                        selectedIndex.value =
                                                            List.from(selectedList
                                                              ..add(index
                                                                  .toDouble()));
                                                      } else {
                                                        selectedIndex.value =
                                                            List.from(selectedList
                                                              ..remove(index
                                                                  .toDouble()));
                                                      }
                                                    } else {

                                                    }
                                                  }),
                                              title: Text('Item on : $index'),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const Divider(
                                            height: 3,
                                          );
                                        },
                                      );
                                    },
                                  )),

                              // Bottom (Cancel or Done)
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                        onPressed: () {

                                          // Go to previous selected values
                                          selectedIndex.value = indexes.map((item) => item.toDouble()).toList(); // Clear selections
                                          Navigator.pop(context);
                                          // jump to 1 and 0 is necessary to call addListener and execute all code below addListener.
                                          // only jump 0, is an edge case when listview is already at 0, then jump 0 wont call addListener
                                          controller.position.jumpTo(1);
                                          controller.position.jumpTo(0); // Reset scroll position
                                        },
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          // jump to 1 and 0 is necessary to call addListener and execute all code below addListener.
                                          // only jump 0, is an edge case when listview is already at 0, then jump 0 wont call addListener
                                          controller.position.jumpTo(1);
                                          controller.position.jumpTo(0); // Reset scroll position
                                        },
                                        child: const Text('Done')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            },

            // appbar-like widget
            child: Container(
              color: Colors.deepPurpleAccent.shade100,
              width: double.infinity,
              height: 100,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Select Fixed Item',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
