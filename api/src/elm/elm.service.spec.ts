import { Test, TestingModule } from '@nestjs/testing';
import { ElmService } from './elm.service';

describe('ElmService', () => {
  let service: ElmService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ElmService],
    }).compile();

    service = module.get<ElmService>(ElmService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
