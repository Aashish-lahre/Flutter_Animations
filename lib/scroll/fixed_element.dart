import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FixedElement extends StatefulWidget {
  const FixedElement({super.key});

  @override
  State<FixedElement> createState() => _FixedElementState();
}

class _FixedElementState extends State<FixedElement> {
  ScrollController controller = ScrollController(initialScrollOffset: 0);
  List<int> indexes = [14, 3]..sort();
  double listTileHeight = 100;
  late List<GlobalKey?> keys;
  List<Positioned> positioned = [];
  int itemCount = 40;

  late final ValueNotifier<List<double>> selectedIndex;

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

  List<List<double>> keyToRenderBoxSizeAndPositionAndMinHeight(
      List<GlobalKey?> keys, List<int> indexes) {
    List<List<double>> sizeAndPositionAndMinHeight = [];
    ('keys lenght in method : $keys');
    for (int i = 0; i < keys.length; i++) {
      Offset position = Offset.zero;
      if (keys[i]!.currentContext != null) {
        position = (keys[i]!.currentContext!.findRenderObject() as RenderBox)
            .localToGlobal(Offset.zero);
      } else {
        position = (indexes[i] * listTileHeight) > controller.position.pixels
            ? (Offset.infinite)
            : -Offset.infinite;
      }
      double minHeight = (sizeAndPositionAndMinHeight.length * 100) + 100;
      sizeAndPositionAndMinHeight.add([listTileHeight, position.dy, minHeight]);
    }
    return sizeAndPositionAndMinHeight;
  }

  @override
  void initState() {
    var temp = indexes;
    selectedIndex = ValueNotifier([3, 14]);
    keys = List.generate(indexes.length, (index) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      controller.position.addListener(() {
        ("keys : ${keys.length}");
        ('indexes : $indexes');
        List<List<double>> sizeAndPositionAndMinHeights =
            keyToRenderBoxSizeAndPositionAndMinHeight(keys, indexes);
        (sizeAndPositionAndMinHeights);

        if (controller.position.userScrollDirection ==
            ScrollDirection.reverse) {
          // scrolling down

          for (int i = 0; i < sizeAndPositionAndMinHeights.length; i++) {
            if (sizeAndPositionAndMinHeights[i][1] <=
                sizeAndPositionAndMinHeights[i][2]) {
              if (positioned.length < i + 1) {
                setState(() {
                  positioned.add(addPositioned(
                      indexes[i], sizeAndPositionAndMinHeights[i][2]));
                });
              }
            }
          }
        } else {
          // scrolling up --> seeing previous content --> more content from up
          if (positioned.isNotEmpty) {
            for (int i = positioned.length - 1; i >= 0; i--) {
              if (sizeAndPositionAndMinHeights[i][1] >=
                  sizeAndPositionAndMinHeights[i][2]) {
                setState(() {
                  positioned.removeLast();
                });
              }
            }
          }
        }

        if (controller.position.pixels == 0) {
          if (indexes == selectedIndex.value) {
            ('No addition and removable of item');
          } else {
            ('danger zone');
            for (var key in keys) {
              key = null;
            }
            positioned.clear();
            setState(() {
              indexes = selectedIndex.value
                  .map((double value) => value.toInt())
                  .toList();
              indexes.sort();
              keys = List.generate(indexes.length, (index) => GlobalKey());
            });
          }
        }
      });
    });

    super.initState();
  }

  List<int> items = List.generate(40, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
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

        // Fixed Tile
        ...positioned,

        // Appbar
        Positioned(
          top: 00,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Center(
                      child: Material(
                        child: Container(
                          width: MediaQuery.of(context).size.width - 50,
                          height: MediaQuery.of(context).size.height - 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
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
                              Expanded(
                                  child: ValueListenableBuilder(
                                valueListenable: selectedIndex,
                                builder: (context, selectedList, child) {
                                  ('indexes at builder : $indexes');
                                  return ListView.separated(
                                    itemCount: itemCount,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: ListTile(
                                          leading: Checkbox(
                                              value:
                                                  selectedList.contains(index)
                                                      ? true
                                                      : false,
                                              onChanged: (flag) {
                                                ('flag : $flag');
                                                ('indexes at onChnaged : $indexes');
                                                if (flag != null) {
                                                  if (flag) {
                                                    ('added');

                                                    ('indexes before adding : $indexes');
                                                    selectedIndex.value =
                                                        List.from(selectedList
                                                          ..add(index
                                                              .toDouble()));
                                                    ('indexes after adding : $indexes');
                                                  } else {
                                                    ('indexes before removing : $indexes');

                                                    selectedIndex.value =
                                                        List.from(selectedList
                                                          ..remove(index
                                                              .toDouble()));
                                                    ('indexes after removing : $indexes');
                                                  }
                                                } else {
                                                  ('flag value is null');
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
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          ('indexes in cancle before empty : $indexes');

                                          selectedIndex.value = [];
                                          ('indexes in listener Cancel : $indexes');
                                          Navigator.pop(context);
                                          controller.position.jumpTo(1);
                                          controller.position.jumpTo(0);
                                        },
                                        child: const Text('Cancle')),
                                    TextButton(
                                        onPressed: () {
                                          ('indexes in listener Done : $indexes');
                                          Navigator.pop(context);
                                          controller.position.jumpTo(1);
                                          controller.position.jumpTo(0);
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
