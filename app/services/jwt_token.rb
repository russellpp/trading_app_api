class JwtToken
    SECRET_KEY = Rails.application.secrets.jwt_secret_key

    def encode_token(payload)
        JWT.encode(payload, SECRET_KEY)
    end

    def decoded_token(auth_header)
        if auth_header
            token = auth_header.split(" ")[1]
            begin
                decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
                
                    # check if the token has expired
                if decoded['exp'] && decoded['exp'] < Time.now.to_i
                    # token has expired
                    return nil
                else
                    # token is valid
                    return decoded
                end
            rescue JWT::DecodeError
                nil
            end
        end
    end

    
    
end

