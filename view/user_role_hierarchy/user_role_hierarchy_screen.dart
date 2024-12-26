import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart' as graph;
import 'package:prestige_prenew_frontend/components/json/master_json.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../style/theme_const.dart';
import '../../components/customs/text_widget.dart';
import '../../components/hover_builder.dart';
import '../../controller/user_role_hierarchy/user_role_hierarchy_controller.dart';

class UserRoleHierarchy extends StatefulWidget {
  const UserRoleHierarchy({super.key});

  @override
  State<UserRoleHierarchy> createState() => _UserRoleHierarchyState();
}

class _UserRoleHierarchyState extends State<UserRoleHierarchy> {
  final formKey = GlobalKey<FormState>();
  final controller = Get.put(UserRoleHierarchyController());
  ScrollController horizontalScroll = ScrollController();
  ScrollController verticalScroll = ScrollController();
  TextEditingController searchController = TextEditingController();
  String? moduleType;
  String? module;
  Map validation = {};
  bool isLoading = false;
  bool buttonLoader = false;
  bool validateForm = false;
  int cursorPos = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        isLoading = true;
      });
      await controller.clearData();
      controller.dialogBoxData.value = await MasterJson.designationFormFields("userrolehierarchy");
      controller.setDefaultData["pagename"] = "userrolehierarchy";
      controller.pageName = "userrolehierarchy";
      controller.getList();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
            backgroundColor: ColorTheme.kScaffoldColor,
            body: dataTable(
              size,
              context,
              size.width,
            ));
      },
    );
  }

  Widget dataTable(
    Size size,
    BuildContext context,
    double boxSize,
  ) {
    graph.BuchheimWalkerConfiguration builder = graph.BuchheimWalkerConfiguration();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                child: TextWidget(
                  text: controller.dialogBoxData["formname"] ?? "",
                  fontSize: 20,
                  fontWeight: FontTheme.notoSemiBold,
                  color: ColorTheme.kPrimaryColor,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 0.5,
                      color: ColorTheme.kBorderColor,
                    ),
                  ),
                  margin: const EdgeInsets.only(right: 20, left: 20, bottom: 20, top: 8),
                  child: !controller.loadingData.value && controller.hierarchyTree.nodeCount() > 0
                      ? InteractiveViewer(
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(100),
                          minScale: 0.01,
                          maxScale: 1,
                          child: graph.GraphView(
                            graph: controller.hierarchyTree,
                            algorithm: graph.BuchheimWalkerAlgorithm(builder, graph.TreeEdgeRenderer(builder)),
                            paint: Paint()
                              ..color = Colors.black
                              ..strokeWidth = 1
                              ..style = PaintingStyle.stroke,
                            builder: (graph.Node node) {
                              var a = node.key!.value.toString();
                              return draggableRectangle(a);
                            },
                          ))
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  bool isDragging = false;

  Widget draggableRectangle(String? a) {
    return Stack(
      children: <Widget>[
        if (isDragging)
          DragTarget<String>(
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return treeNode(a);
            },
            onAccept: (String data) async {
              if (data == a || a == null) {
                return;
              }
              Map<String, dynamic> node = controller.findNodeById(targetId: data) ?? {};
              if (controller.findNodeInFamily(targetId: a, treeData: node) != null) {
                return;
              }
              String? parentId = controller.removeNode(id: data);
              if (parentId != null) {
                controller.addNode(
                  parentId: a,
                  newChild: node,
                );
              }
              await controller.updateData();
              setState(() {});
            },
          ),
        if (!isDragging)
          Draggable<String>(
              data: a,
              feedback: treeNode(a),
              onDragStarted: () {
                setState(() {
                  isDragging = true;
                });
              },
              onDragCompleted: () {
                setState(() {
                  isDragging = false;
                });
              },
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  isDragging = false;
                });
              },
              childWhenDragging: const SizedBox(
                width: 150,
                height: 100,
              ),
              child: treeNode(a)),
      ],
    );
  }

  Widget treeNode(String? a) {
    Map? node = controller.findNodeById(targetId: a ?? '');

    return HoverBuilder(
      builder: (isHovered) {
        return SizedBox(
          height: 90.0,
          width: 150.0,
          child: Stack(
            children: [
              Container(
                height: 75.0,
                width: 150.0,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: ColorTheme.kBorderColor),
                  borderRadius: BorderRadius.circular(8),
                  color: ColorTheme.kBorderColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Center(
                          child: Text(
                            '${node?['title']}',
                            style: const TextStyle(fontSize: 18),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 55,
                child: AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: SizedBox(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        HoverBuilder(
                          builder: (isHovered) => Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorTheme.kWhite,
                              boxShadow: isHovered
                                  ? [
                                      BoxShadow(
                                        color: ColorTheme.kBlack.withOpacity(0.4),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkResponse(
                                  onTap: () async {
                                    if (a == null) return;
                                    await controller.addUsersToNode(a);
                                    List<Map<String, dynamic>> nodes =
                                        List.from(controller.setDefaultData["masterFormData"].where((item) => item['isSelected'] == true).toList().map(
                                      (e) {
                                        return {'_id': e['_id'], 'title': e['userrole'], 'name': e['userrole'], 'children': [], 'pid': a};
                                      },
                                    ));
                                    if (nodes.isEmpty) return;
                                    for (var node in nodes) {
                                      controller.setDefaultData['data'] = controller.addChildById(parent: controller.setDefaultData['data'], parentId: a, newChild: node, flag: 1);
                                    }
                                    controller.generateTree();
                                    controller.updateData();
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color: isHovered ? Colors.blue : const Color(0xFF9F9F9F),
                                  )),
                            ),
                          ),
                        ),
                        if (node!.containsKey('pid') && node['pid'] != null && node['pid'].toString().isNotEmpty)
                          HoverBuilder(builder: (isHovered) {
                            return Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorTheme.kWhite,
                                boxShadow: isHovered
                                    ? [
                                        BoxShadow(
                                          color: ColorTheme.kBlack.withOpacity(0.4),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkResponse(
                                  onTap: () async {
                                    if (a == null) return;
                                    Map? deletedNode = controller.findNodeById(targetId: a);
                                    if (deletedNode == null) return;
                                    controller.setDefaultData['data'] = controller.removeChildById(controller.setDefaultData['data'], a);
                                    if (deletedNode['children'] != null) {
                                      controller.setDefaultData['data'] = controller.addChildById(
                                          parent: controller.setDefaultData['data'],
                                          parentId: deletedNode['pid'],
                                          newChildren: List<Map<String, dynamic>>.from(deletedNode['children']),
                                          flag: 1);
                                    }
                                    await controller.updateData();
                                    controller.generateTree();
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: isHovered ? ColorTheme.kErrorColor : const Color(0xFF9F9F9F),
                                  ),
                                ),
                              ),
                            );
                          }),
                        HoverBuilder(builder: (isHovered) {
                          return Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorTheme.kWhite,
                              boxShadow: isHovered
                                  ? [
                                      BoxShadow(
                                        color: ColorTheme.kBlack.withOpacity(0.4),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkResponse(
                                  onTap: () async {
                                    if (a == null) return;
                                    controller.showUserList(a);
                                  },
                                  child: Icon(
                                    Icons.info,
                                    color: isHovered ? ColorTheme.kWarnColor : const Color(0xFF9F9F9F),
                                  )),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
