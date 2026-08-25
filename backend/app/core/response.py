def success_response(data=None, message="Operação realizada com sucesso."):
    # retorna um dicionário com success, message e data
    return {   
        "success": True,
        "message": message,
        "data": data
    }

def error_response(message, errors=None):
    # retorna um dicionário com success False, message e errors
    return {
        "success": False,
        "message": message,
        "errors": errors
    }