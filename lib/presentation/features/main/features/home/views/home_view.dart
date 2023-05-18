import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../core/extensions/context_extension.dart';
import '../../../../../../utils/logic/helpers/google-maps/google_maps_helper.dart';
import '../../../../../../utils/ui/constants/colors/app_colors.dart';
import '../../../../../components/custom_circle_button.dart';
import '../../../../../widgets/expandable_page_view.dart';
import '../components/event_card.dart';
import '../state/cubit/home_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeCubit readHomeCubit = context.read<HomeCubit>();
    HomeCubit watchHomeCubit = context.watch<HomeCubit>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
              top: context.topPadding,
            ),
            initialCameraPosition: CameraPosition(
              target: readHomeCubit.state.myPosition,
              zoom: 10.5,
            ),
            onMapCreated: (controller) async {
              /*String dark =
                  await rootBundle.loadString('assets/google-maps/dark.txt');
              controller.setMapStyle(dark);*/

              readHomeCubit.homeViewModel.controller = controller;
              readHomeCubit.setMyPosition(
                await GoogleMapsHelper.instance
                    .animateCameraToMyLocation(controller),
              );
            },
            markers: readHomeCubit.homeViewModel.events.map(
              (e) {
                return Marker(
                  markerId: MarkerId(e[0]),
                  position: LatLng(
                    e[1][0],
                    e[1][1],
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    e[0] == watchHomeCubit.state.markerId
                        ? BitmapDescriptor.hueAzure
                        : BitmapDescriptor.hueRed,
                  ),
                  onTap: () {
                    readHomeCubit.homeViewModel.onTapMarker(context, e[0]);
                  },
                );
              },
            ).toSet(),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: readHomeCubit.state.markerId.isNotEmpty,
                child: ExpandablePageView.builder(
                  itemCount: 5,
                  controller: readHomeCubit.homeViewModel.pageController,
                  padEnds: false,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return const EventCard();
                  },
                  onPageChanged: (index) {
                    readHomeCubit.homeViewModel
                        .onEventPageChanged(context, index);
                  },
                ),
              ),
            ),
          ),
          Positioned(
            top: context.topPadding + 3,
            right: 10,
            child: CustomCircleButton(
              color: AppColors.mainColor2,
              child: const FaIcon(
                FontAwesomeIcons.locationCrosshairs,
              ),
              onTap: () async {
                readHomeCubit.setMyPosition(
                  await GoogleMapsHelper.instance.animateCameraToMyLocation(
                    readHomeCubit.homeViewModel.controller,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
