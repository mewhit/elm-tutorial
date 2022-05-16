import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({ origin: ["http://localhost:4040", "https://elm-tutorial.netlify.app/"] })


  await app.listen(process.env.PORT || 3000);
}
bootstrap();
