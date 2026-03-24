classdef S_handle < handle
    properties
        % setting 
        is_power
        is_overwrite
        is_test
        is_parfor
    end
    methods
        function obj = S_handle()
            obj.is_power = true;
            obj.is_overwrite = false;   
            obj.is_test = false;  
            obj.is_parfor = false;
        end
        function copy_handle_settings(obj, Shandle)
            obj.is_power = Shandle.is_power;
            obj.is_overwrite = Shandle.is_overwrite;
            obj.is_test = Shandle.is_test;
            obj.is_parfor = Shandle.is_parfor;
        end
        function test_on(obj)
            obj.is_test = true;
        end
        function test_off(obj)
            obj.is_test = false;
        end
        function power_on(obj)
            obj.is_power = true;
        end
        function power_off(obj)
            obj.is_power = false;
        end
        function overwrite_on(obj)
            W.warning('overwrite on');
            obj.is_overwrite = true;
        end
        function overwrite_off(obj)
            obj.is_overwrite = false;
        end
        function parfor_on(obj)
            W.print('parfor on');
            obj.is_parfor = true;
        end
        function parfor_off(obj)
            obj.is_parfor = false;
        end
    end
end