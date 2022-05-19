import { Test, TestingModule } from '@nestjs/testing';
import { ExcerciseService } from './excercise.service';

describe('ExcerciseService', () => {
  let service: ExcerciseService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ExcerciseService],
    }).compile();

    service = module.get<ExcerciseService>(ExcerciseService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
