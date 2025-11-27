import 'dart:io';

import '../entities/edit_result.dart';
import '../entities/photo.dart';

abstract class AIProcessingRepository {
  Future<EditResult> enhancePhoto(File image, {int? intensity});

  Future<EditResult> restorePhoto(
    File image, {
    bool colorize = false,
    bool removeDamage = true,
  });

  Future<EditResult> editSelfie(
    File image, {
    int? smoothness,
    int? brighten,
    bool? removeAcne,
  });

  Future<EditResult> faceSwap(File sourceImage, File targetImage);

  Future<EditResult> applyAging(File image, int targetAge);

  Future<EditResult> generateBaby(File parentImage1, File parentImage2);

  Future<EditResult> animatePhoto(File image, String animationType);

  Future<EditResult> applyStyleTransfer(File image, String style);

  Future<EditResult> upscaleImage(File image, {int factor = 2});

  Future<EditResult> applyFilter(File image, String filterName);

  Future<PhotoStatus> checkProcessingStatus(String processId);
}





