import { Test, TestingModule } from '@nestjs/testing';
import { ExcerciseSolutionService } from './excercise-solution.service';

describe('ExcerciseSolutionService', () => {
  let service: ExcerciseSolutionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ExcerciseSolutionService],
    }).compile();

    service = module.get<ExcerciseSolutionService>(ExcerciseSolutionService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
