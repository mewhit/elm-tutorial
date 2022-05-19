import { Test, TestingModule } from '@nestjs/testing';
import { ExcerciseController } from './excercise.controller';

describe('ExcerciseController', () => {
  let controller: ExcerciseController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ExcerciseController],
    }).compile();

    controller = module.get<ExcerciseController>(ExcerciseController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
