// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kidsero_driver/core/network/api_service.dart';
// import 'package:kidsero_driver/features/children/cubit/children_cubit.dart';
// import 'package:kidsero_driver/features/children/model/child_model.dart'; // Import cubit

// class ChildrenScreen extends StatelessWidget {
//   const ChildrenScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ChildrenCubit(context.read<ApiService>())..loadChildren(),
//       child: Scaffold(
        
//         floatingActionButton: Builder(
//           builder: (context) {
//             return FloatingActionButton.extended(
//               onPressed: () => _showAddChildDialog(context),
//               backgroundColor: const Color(0xFF4F46E5),
//               icon: const Icon(Icons.add),
//               label: const Text("Add Child"),
//             );
//           }
//         ),
//         body: NestedScrollView(
//            headerSliverBuilder: (context, innerBoxIsScrolled) {
//             return [
//               SliverAppBar(
//                 expandedHeight: 60,
//                 floating: false,
//                 pinned: true,
        
//                 flexibleSpace: FlexibleSpaceBar(
//                   title: Text("My Children", style: TextStyle(color: Colors.white, fontSize: 16)),
//                   background: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ];
//           },
//           body: BlocConsumer<ChildrenCubit, ChildrenState>(
//             listener: (context, state) {
//               if (state is ChildAddSuccess) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(state.message), backgroundColor: Colors.green),
//                 );
//                 Navigator.of(context).pop(); // Close dialog if open
//               } else if (state is ChildrenError) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//                 );
//               }
//             },
//             buildWhen: (previous, current) => 
//                 current is ChildrenLoaded || current is ChildrenLoading,
//             builder: (context, state) {
//               if (state is ChildrenLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (state is ChildrenLoaded) {
//                 if (state.children.isEmpty) {
//                   return const Center(child: Text("No children added yet."));
//                 }
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: state.children.length,
//                   itemBuilder: (context, index) {
//                     return _buildChildCard(state.children[index]);
//                   },
//                 );
//               }
//               return const SizedBox();
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAddChildDialog(BuildContext parentContext) {
//     final TextEditingController _codeController = TextEditingController();

//     showDialog(
//       context: parentContext,
//       builder: (context) {
//         // Use BlocProvider.value to give the dialog access to the existing Cubit
//         return BlocProvider.value(
//           value: parentContext.read<ChildrenCubit>(),
//           child: AlertDialog(
//             title: const Text("Add New Child"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text("Enter the code provided by the school."),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _codeController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: "Child Code",
//                     hintText: "e.g., F6TG8",
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Cancel"),
//               ),
//               BlocBuilder<ChildrenCubit, ChildrenState>(
//                 builder: (context, state) {
//                   if (state is ChildAddLoading) {
//                     return const CircularProgressIndicator();
//                   }
//                   return ElevatedButton(
//                     onPressed: () {
//                       if (_codeController.text.isNotEmpty) {
//                         context.read<ChildrenCubit>().addChild(_codeController.text);
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
//                     child: const Text("Add", style: TextStyle(color: Colors.white)),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildChildCard(Child child) {
//     final bool isActive = child.status.toLowerCase() == 'active';
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             // Avatar
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: Colors.grey[200],
//               backgroundImage: child.avatar != null ? NetworkImage(child.avatar!) : null,
//               child: child.avatar == null ? const Icon(Icons.person, size: 30) : null,
//             ),
//             const SizedBox(width: 16),
//             // Info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         child.name,
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: isActive ? Colors.green : Colors.red),
//                         ),
//                         child: Text(
//                           child.status.toUpperCase(),
//                           style: TextStyle(
//                             fontSize: 10, 
//                             fontWeight: FontWeight.bold,
//                             color: isActive ? Colors.green : Colors.red,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "Grade: ${child.grade ?? '-'} • Class: ${child.classroom ?? '-'}",
//                     style: TextStyle(color: Colors.grey[600], fontSize: 13),
//                   ),
//                   const SizedBox(height: 8),
//                   if (child.organization != null)
//                     Row(
//                       children: [
//                         if (child.organization!.logo != null)
//                           Image.network(child.organization!.logo!, width: 20, height: 20),
//                         const SizedBox(width: 6),
//                         Text(
//                           child.organization!.name,
//                           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/core/theme/app_colors.dart';
import 'package:kidsero_driver/features/children/cubit/children_cubit.dart';
import 'package:kidsero_driver/features/children/model/child_model.dart';

class ChildrenScreen extends StatelessWidget {
  const ChildrenScreen({Key? key}) : super(key: key);

  // Define theme colors locally for consistency
  final Color primaryColor = const Color(0xFF4F46E5);
  final Color secondaryColor = const Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChildrenCubit(context.read<ApiService>())..loadChildren(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB), // Softer background color
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 60, // Taller header for a modern look
               floating: false,
                pinned: true,
                backgroundColor: primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    "My Children",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // centerTitle: false,
                  // titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryColor, secondaryColor],
                      ),
                    ),
                    // Add a subtle decorative pattern
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Icon(Icons.family_restroom, 
                            size: 150, 
                            color: Colors.white.withOpacity(0.1)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: BlocConsumer<ChildrenCubit, ChildrenState>(
            listener: (context, state) {
              if (state is ChildAddSuccess) {
                Navigator.of(context).pop(); // Close bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(state.message),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is ChildrenError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message), 
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            buildWhen: (previous, current) =>
                current is ChildrenLoaded || current is ChildrenLoading,
            builder: (context, state) {
              if (state is ChildrenLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ChildrenLoaded) {
                if (state.children.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                  itemCount: state.children.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ChildCard(child: state.children[index]);
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () => _showAddChildSheet(context),
              backgroundColor: primaryColor,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: AppColors.background),
              label: const Text(
                "Add Child",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.background),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            "No Children Added Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the button below to link your\nchild's school account.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAddChildSheet(BuildContext parentContext) {
    final TextEditingController codeController = TextEditingController();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true, // Allows sheet to go full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Re-provide the cubit to the sheet
        return BlocProvider.value(
          value: parentContext.read<ChildrenCubit>(),
          child: Padding(
            // Handle keyboard overlapping
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Link New Child",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter the unique code provided by the school administration.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: "Child Code",
                    hintText: "e.g., F6TG8",
                    prefixIcon: const Icon(Icons.qr_code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<ChildrenCubit, ChildrenState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is ChildAddLoading
                            ? null
                            : () {
                                if (codeController.text.isNotEmpty) {
                                  context
                                      .read<ChildrenCubit>()
                                      .addChild(codeController.text);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: state is ChildAddLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Add Child",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Extracted Child Card Widget
// -----------------------------------------------------------------------------

class _ChildCard extends StatelessWidget {
  final Child child;

  const _ChildCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isActive = child.status.toLowerCase() == 'active';
    final Color statusColor = isActive ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Status Indicator Bar
              Container(
                width: 6,
                color: statusColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar with border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[100]!, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: child.avatar != null
                              ? NetworkImage(child.avatar!)
                              : null,
                          child: child.avatar == null
                              ? Icon(Icons.person,
                                  size: 30, color: Colors.grey[400])
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _buildStatusBadge(isActive, child.status),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Class Info
                            Text(
                              "${child.grade ?? 'No Grade'}  •  ${child.classroom ?? 'No Class'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Organization Info
                            if (child.organization != null)
                              Row(
                                children: [
                                  Icon(Icons.school,
                                      size: 14, color: Colors.grey[400]),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      child.organization!.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, String statusText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: isActive ? Colors.green[700] : Colors.red[700],
        ),
      ),
    );
  }
}
