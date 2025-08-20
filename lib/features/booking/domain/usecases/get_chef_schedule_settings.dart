import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/chef_schedule_settings.dart';
import '../repositories/chef_schedule_repository.dart';

class GetChefScheduleSettings {
  final ChefScheduleRepository repository;

  const GetChefScheduleSettings(this.repository);

  Future<Either<Failure, ChefScheduleSettings>> call(GetChefScheduleSettingsParams params) async {
    if (params.chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    return await repository.getScheduleSettings(chefId: params.chefId);
  }
}

class GetChefScheduleSettingsParams {
  final String chefId;

  const GetChefScheduleSettingsParams({
    required this.chefId,
  });
}