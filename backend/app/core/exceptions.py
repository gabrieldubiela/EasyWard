class NotFoundError(Exception):
    def __init__(self, message: str):
        self.message = message
        super().__init__(self.message)

class PermissionDeniedError(Exception):
    def __init__(self, message: str):
        self.message = message
        super().__init__(self.message)

class BusinessRuleError(Exception):
    def __init__(self, message: str):
        self.message = message
        super().__init__(self.message)

class UnauthorizedError(Exception):
    def __init__(self, message: str):
        self.message = message
        super().__init__(self.message)

class ConflictError(Exception):
    def __init__(self, message: str):
        self.message = message
        super().__init__(self.message)