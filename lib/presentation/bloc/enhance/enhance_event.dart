import 'package:equatable/equatable.dart';

enum EnhanceType {
  auto,
  portrait,
  landscape,
  lowLight,
  hdr,
}

abstract class EnhanceEvent extends Equatable {
  const EnhanceEvent();

  @override
  List<Object?> get props => [];
}

/// Load the image to be enhanced
class EnhanceImageLoaded extends EnhanceEvent {
  final String imagePath;

  const EnhanceImageLoaded(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Start the enhancement process
class EnhanceRequested extends EnhanceEvent {
  const EnhanceRequested();
}

/// Change the enhancement type
class EnhanceTypeChanged extends EnhanceEvent {
  final EnhanceType type;

  const EnhanceTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Change the intensity level
class EnhanceIntensityChanged extends EnhanceEvent {
  final double intensity;

  const EnhanceIntensityChanged(this.intensity);

  @override
  List<Object?> get props => [intensity];
}

/// Reset to original image
class EnhanceReset extends EnhanceEvent {
  const EnhanceReset();
}

/// Save the enhanced image
class EnhanceSaveRequested extends EnhanceEvent {
  const EnhanceSaveRequested();
}

/// Update comparison slider position
class EnhanceComparisonChanged extends EnhanceEvent {
  final double position;

  const EnhanceComparisonChanged(this.position);

  @override
  List<Object?> get props => [position];
}

