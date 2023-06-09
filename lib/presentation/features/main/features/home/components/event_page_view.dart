import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../utils/logic/state/cubit/chat-socket/chat_socket_cubit.dart';
import '../../../../../widgets/expandable_page_view.dart';
import '../state/cubit/home_cubit.dart';
import 'event-card/event_card.dart';

class EventPageView extends StatefulWidget {
  const EventPageView({Key? key}) : super(key: key);

  @override
  State<EventPageView> createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeCubit readHomeCubit = context.read<HomeCubit>();

    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.isChosenMarker) {
          animationController.forward();
        } else {
          animationController.reverse();
        }
      },
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animationController),
        child: context.watch<ChatSocketCubit>().state.closeEvents.isNotEmpty
            ? ExpandablePageView.builder(
                itemCount:
                    context.read<ChatSocketCubit>().state.closeEvents.length,
                controller: readHomeCubit.homeViewModel.pageController,
                padEnds: false,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return EventCard(
                    eventModel: context
                        .read<ChatSocketCubit>()
                        .state
                        .closeEvents[index],
                  );
                },
                onPageChanged: (index) {
                  readHomeCubit.homeViewModel.onEventPageChanged(index);
                },
              )
            : null,
      ),
    );
  }
}
