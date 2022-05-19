import { Test, TestingModule } from '@nestjs/testing';
import { ExcerciseSolutionResolver } from './excercise-solution.resolver';

describe('ExcerciseSolutionResolver', () => {
  let resolver: ExcerciseSolutionResolver;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ExcerciseSolutionResolver],
    }).compile();

    resolver = module.get<ExcerciseSolutionResolver>(ExcerciseSolutionResolver);
  });

  it('should be defined', () => {
    expect(resolver).toBeDefined();
  });
});
