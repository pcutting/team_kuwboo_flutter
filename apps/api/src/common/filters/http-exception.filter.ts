import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status =
      exception instanceof HttpException ? exception.getStatus() : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.getResponse()
        : { message: 'Internal server error' };

    // Log non-HttpException errors with full stack so 500s aren't a
    // black box. HttpException 4xx are intentional (validation, auth)
    // — log those at debug level only to avoid noise.
    if (!(exception instanceof HttpException)) {
      const err = exception as Error;
      this.logger.error(
        `Unhandled ${request.method} ${request.url}: ${err?.message ?? exception}`,
        err?.stack,
      );
    } else if (status >= 500) {
      this.logger.error(
        `HttpException ${status} on ${request.method} ${request.url}`,
        exception.stack,
      );
    }

    const body = typeof message === 'string' ? { message } : message;

    response.status(status).json({
      ...body,
      statusCode: status,
      timestamp: new Date().toISOString(),
    });
  }
}
